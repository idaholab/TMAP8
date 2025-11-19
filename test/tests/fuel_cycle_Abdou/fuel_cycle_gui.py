#! /usr/bin/env python
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 11 15:33:07 2024
This file creates a GUI interface that can be used to adjust the parameters in
the TMAP8 fuel cycle model.
"""
import tempfile
import tkinter as tk
import tkinter.ttk as ttk
import re
import subprocess
from matplotlib.backends.backend_tkagg import (FigureCanvasTkAgg, NavigationToolbar2Tk)
from matplotlib.backend_bases import key_press_handler
from matplotlib.figure import Figure
import numpy as np
import scipy.constants as scc
import atexit
#import asyncio
import os
import shutil
import argparse
import PIL
dir_path = os.path.dirname(os.path.realpath(__file__))
icon_path = os.path.join(dir_path,'..','..','..','doc','content','figures','TMAP8_logo','TMAP8_vertical_blue.png')

class fake_tk():
    def __init__(self,x=0,text=None,row=0,column=0,grid=None,textvariable=None,validate=None,validatecommand=None, width=True, height=True,master=None,**kwargs):
        if text is not None:
            self.x = text
            self.text = text
        else:
            self.x = x
        if textvariable is not None:
            self.x = textvariable
        self.__dict__[0] = 1
        self.__dict__.update(**kwargs)
        self._tkcanvas = self
        self.figure = self
        self.bbox = self
        self.width = 1
        self.height = 1
        self.mpl_connect = self
        self.yview = None
        self.columnconfigure = self.rowconfigure = self.create_window = self.configure
        self.bind = self.configure

    def configure(self,*args,**kwargs):
        return True
    def get(self):
        if 'values' in self.__dict__.keys():
            return self.values[0]
        if type(self.x) is type(self):
            return str(self.x)
        else:
            return self.x
    def cget(self,index):
        return self[index]
    def __call__(self,*args,**kwargs):
        pass
    def set(self,x):
        self.x = x
    def grid(self,row=0,column=0,**kwargs):
        return True
    def update(self):
        return True
    def current(self, indice):
        self.x.set(indice)
    def __setitem__(self, key, value):
        setattr(self, key, value)
    def __getitem__(self, key):
        getattr(self, key)
    def trace(self,*args,**kwargs):
        pass
    def draw(self):
        pass
    def __str__(self):
        if type(self.x) is type(self):
            return self.x.__str__()
        else:
            return self.x
    def __repr__(self):
        if type(self.x) is type(self):
            return self.x.__str__()
        else:
            return str(self.x)

class fuel_cycle_form(tk.Tk):
    def __init__(self, interval=1/120,tmap8_path=None,headless=False):
        self.headless = headless
        if not headless:
            super().__init__()
        else:
            self.register = lambda x, *args, **kwargs: True
            self.update = lambda: True
            self.destroy = self.cleanup
        if tmap8_path is None:
            check_paths = [os.path.join(dir_path,'..','..','..','tmap8-opt'),
                           os.path.join(dir_path,'..','..','..','tmap8-dbg'),
                           os.path.join(dir_path,'..','..','..','tmap8-devel'),
                           os.path.join(dir_path,'..','..','..','tmap8-oprof')]
            for check_path in check_paths:
                if tmap8_path is None:
                    if os.path.isfile(check_path) and os.access(check_path, os.X_OK):
                        tmap8_path = check_path
            for check_path in check_paths:
                if tmap8_path is None:
                    tmap8_path = shutil.which(check_path[check_path.rfind('/')+1:])
        self.tmap8_path = tmap8_path
        if tmap8_path is None or not (os.path.isfile(self.tmap8_path) and os.access(self.tmap8_path, os.X_OK)):
            raise OSError('Unable to locate a working TMAP8 executable')
        pattern = re.compile('\\[(?P<variable>[0-9a-zA-Z_]+)\\]\ntype = ConstantPostprocessor\nexecute_on = \'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR\'\nvalue\\s?=\\s*(?P<valnum>[0-9e.-]+)\n\\[]',re.MULTILINE)
        instring = ''
        test_path = os.path.join(dir_path,'fuel_cycle.i')
        self.gold_path = os.path.join(dir_path,'gold','fuel_cycle_out.csv')
        if not os.path.isfile(test_path):
            raise OSError('Unable to locate the fuel cycle input file')
        with open(test_path,'r') as infile:
            instring = infile.read()
        ic_loc = instring.find('initial_condition')
        ic_end = instring.find('\n',ic_loc)
        start = instring.find('Postprocessors]')+len('Postprocessors]\n')
        end = instring.find('  [T_BZ')
        self.top_header = instring[:ic_loc]
        self.bottom_header = instring[ic_end:start]
        self.footer = instring[end:]
        filtstring = [x[:x.find('#')].strip() if '#' in x else x for x in instring[start:end].split('\n')]
        self.filtstring = '\n'.join([x.strip() for x in filtstring if len(x.strip())>1])
        self.matches = [(m.span(), m.groups()) for m in pattern.finditer(self.filtstring)]
        labels = []
        self.entries = []
        self.plot_vars = []
        tvariables = {}
        row_i = 1
        if not headless:
            label = tk.Label(self, text='Variable')
        else:
            label = fake_tk(grid=lambda row, column: True)
        _,self.tmpfile = tempfile.mkstemp(suffix='.i')
        atexit.register(self.cleanup)
        label.grid(row=0,column=0)
        newlabel = tk.Label(self, text='Value')
        newlabel.grid(row=0,column=1)
        newlabel = tk.Label(self, text='Plot')
        newlabel.grid(row=0,column=2)
        self.param_frame = tk.Frame(self,borderwidth=0)
        self.param_frame.grid(row=1,column=0,columnspan=2,rowspan=2,sticky='news')
        self.scroll_can = tk.Canvas(self.param_frame,borderwidth=0)
        self.scrollable = tk.Frame(self.scroll_can)
        scrollbar = tk.Scrollbar(self.param_frame,orient="vertical",command=self.scroll_can.yview)
        self.scroll_can.configure(yscrollcommand=scrollbar.set)
        self.scroll_can.grid(row=0,column=0,sticky='news')
        scrollbar.grid(row=0,column=1,sticky='news')
        self.param_frame.columnconfigure(0,weight=1)
        self.param_frame.rowconfigure(0,weight=1)
        self.scroll_can.create_window((8,4),window=self.scrollable,tags="self.frame",anchor='nw')
        self.scrollable.bind("<Configure>", self.onFrameConfigure)
        output_var = tk.StringVar()
        self.plot_ints = []
        self.checkboxes = []
        self.first_run = True
        label = tk.Label(self.scrollable, text="Initial storage")
        entryval = tk.StringVar()
        self.float_validator = (self.register(self.float_validation), '%d','%i', '%P', '%s', '%S', '%v', '%V', '%W')
        textwidget = tk.Entry(self.scrollable,textvariable=entryval,validate='key', validatecommand=self.float_validator)
        entryval.set("225.4215")
        self.init_storage = textwidget
        labels.append(label)
        label.update()
        textwidget.update()
        row_i = 0
        label.grid(row=row_i, column=0)
        textwidget.grid(row=row_i, column=1)
        row_i+=1
        for match in self.matches:
            label = tk.Label(self.scrollable, text=match[1][0])
            entryval = tk.StringVar()
            textwidget = tk.Entry(self.scrollable, text=match[1][0],textvariable=entryval, validate='key', validatecommand=self.float_validator)
            entryval.set(match[1][1])
            self.entries.append(textwidget)
            labels.append(label)
            label.update()
            textwidget.update()
            label.grid(row=row_i, column=0)
            textwidget.grid(row=row_i, column=1)
            row_i+=1
        self.input_entries = self.entries
        plotlabel = tk.Label(self.scrollable,text='Time Units')
        plotlabel.grid(row=row_i,column=0)
        self.time_unit = tk.StringVar()
        self.time_combobox = ttk.Combobox(self.scrollable,width=20,textvariable=self.time_unit)
        self.time_combobox['values'] = ('seconds','hours','days','months','years')
        self.time_combobox.current(0)
        self.time_divisors = {0:1,'seconds':1,'minutes':scc.minute,'hours':scc.hour,'days':scc.day,'months':scc.year/12,'years':scc.year}
        self.old_timescale = self.time_divisors[self.time_unit.get()]
        self.time_unit.trace('w',self.change_scale)
        if not headless:
            self.update()
        self.entries.append(self.time_combobox)
        self.time_combobox.grid(row=row_i,column=1)
        row_i+=1
        self.labeldict = {}
        for label, x in zip(self.matches, self.input_entries):
            try:
                self.labeldict[label[1][0]]=float(x.get())
            except ValueError:
                x_str = x.get()
                try:
                    self.labeldict[label[1][0]]=float(x.get().replace('e','').replace('-',''))
                except ValueError:
                    raise ValueError('Non-numeric value in parameter definition during creation')
                    self.destroy()

        run_button = tk.Button(self,text="Run",command=self.buttonClick)
        run_button.grid(row=3,column=1)
        self.number_rows = row_i
        self.create_plot()
    def float_validation(self,action,index,value_if_allowed, prior_value, text, validation_type, trigger_type, widget_name):
        if value_if_allowed:
            try:
                float(value_if_allowed)
                return True
            except ValueError:
                try:
                    float(value_if_allowed.replace('e','').replace('-',''))
                    return True
                except ValueError:
                    return False
                return False
        else:
            return False

    def onFrameConfigure(self, event):
        self.scroll_can.configure(scrollregion=self.scroll_can.bbox("all"))
    def onListConfigure(self, event):
        self.cbcanvas.configure(scrollregion=self.cbcanvas.bbox("all"))

    def test_compare(self):
        check_one = np.genfromtxt(self.tmpfile[:-2]+'_out.csv',skip_header=1,delimiter=',')
        check_two = np.genfromtxt(self.gold_path,              skip_header=1,delimiter=',')
        if not np.array_equal(check_one, check_two):
            return sum((check_one[-1,:]-check_two[-1,:])**2) < 1e-10
        else:
            return np.array_equal(check_one, check_two)

    def apply_template(self,vals):
        outstring = self.top_header
        pointer = 0
        try:
            ins = float(self.init_storage.get())
            outstring+='initial_condition = {:f}'.format(ins)
        except ValueError:
            try:
                ins=float(self.init_storage.get().replace('e','').replace('-',''))
                outstring+='initial_condition = {:f}'.format(ins)
            except ValueError:
                raise ValueError('Non-numeric value in initial storage definition')
                self.destroy()

        outstring+=self.bottom_header
        for match in self.matches:
            outstring+=self.filtstring[pointer:match[0][0]]
            outstring+='  [{:s}]\n    type = ConstantPostprocessor\n    execute_on = \'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR\'\n'.format(match[1][0])
            try:
                outstring+='    value = '+str(vals[match[1][0]])+'\n  []\n'
            except ValueError:
                try:
                    ins=float(vals[match[1][0]].replace('e','').replace('-',''))
                    outstring+='    value = '+str(ins)+'\n  []\n'
                except ValueError:
                    raise ValueError('Non-numeric value in parameter definition {:s}'.format(match[1][0]))
                    self.destroy()
            pointer = match[0][1]
        outstring+= self.filtstring[pointer:]
        outstring+=self.footer
        return outstring

    def create_plot(self):
        fig = Figure(figsize=(6,4), dpi=150)
        self.ax = fig.add_subplot(111)
        self.canvas = FigureCanvasTkAgg(fig, master=self)
        self.canvas._tkcanvas.grid(row=2,column=2)
        self.canvas.draw()
        self.toolbar = NavigationToolbar2Tk(self.canvas,self,pack_toolbar=False)
        self.toolbar.update()
        self.toolbar.grid(row=3,column=2)
        self.canvas.mpl_connect("key_press_event", self.on_key_press)
        self.lines = self.ax.plot([],[])
        if not self.headless:
            self.ax.set_xlabel('Time [{:s}]'.format(self.time_unit.get()))
            self.ax.set_ylabel('Tritium [kg]')
            self.ax.set_xlim(0,8.64e8/self.time_divisors[self.time_unit.get()])

    def on_key_press(self,event):
        key_press_handler(event,self.canvas,self.toolbar)

    def buttonClick(self):
        output_string = ""
        for label, x in zip(self.matches, self.input_entries):
            try:
                self.labeldict[label[1][0]]=float(x.get())
            except ValueError:
                x_str = x.get()
                try:
                    self.labeldict[label[1][0]]=float(x.get().replace('e','').replace('-',''))
                except ValueError:
                    raise ValueError('Non-numeric value in parameter definition during creation')
                    self.destroy()

        output_string = self.apply_template(self.labeldict)
        with open(self.tmpfile,'w') as outfile:
            outfile.write(output_string)
        self.proc = subprocess.Popen([self.tmap8_path, '-i',self.tmpfile],stdout=subprocess.PIPE,stderr=subprocess.PIPE,cwd=os.path.dirname(self.tmpfile))
        stdout, stderr = self.proc.communicate()
        with open(self.tmpfile[:-2]+'_out.csv','r') as infile:
            self.data_labels = infile.readline()[:-1].split(',')
            self.iz_data = np.genfromtxt(self.tmpfile[:-2]+'_out.csv',skip_header=1,delimiter=',')
        row_i=1
        self.ax.clear()
        if self.first_run:
            self.cbframe = tk.Frame(self,borderwidth=0)
            self.cbframe.rowconfigure(0,weight=1)
            self.cbframe.columnconfigure(0,weight=1)
            self.cbframe.grid(row=1,column=2,sticky='news')
            self.cbcanvas = tk.Canvas(self.cbframe,borderwidth=0)
            self.cblable = tk.Frame(self.cbcanvas)
            scrollbar = tk.Scrollbar(self.cbframe,orient="vertical",command=self.cbcanvas.yview)
            self.cbcanvas.configure(yscrollcommand=scrollbar.set)
            self.cbcanvas.grid(row=0,column=0,sticky='news')
            scrollbar.grid(row=0,column=1,sticky='nws')
            self.cbcanvas.create_window((8,4),window=self.cblable,tags="self.frame",anchor='nw')
            self.cblable.bind("<Configure>", self.onListConfigure)
            for label in self.data_labels[1:]:
                plotint = tk.IntVar()
                checkbutton = tk.Checkbutton(self.cblable,variable=plotint,onvalue=1,offvalue=0,command=self.update_ydata,text=label)
                self.checkboxes.append(checkbutton)
                self.plot_ints.append(plotint)
                checkbutton.grid(row=row_i, column=2)
                self.cbframe.columnconfigure(row_i,weight=1)
                row_i+=1
            self.first_run = False
        self.update_ydata()
        self.update_plot()
        self.update()

    def update_plot(self):
        i=0
        j=1
        count = sum([x.get() for x in self.plot_ints])
        if count > len(self.ax.get_lines()):
            for indice in range(count - len(self.ax.get_lines())):
                self.ax.plot([],[])
        self.lines = self.ax.get_lines()
        maximum = 0
        minimum = 1e9
        for pli in self.plot_ints:
            if pli.get()>0:
                self.lines[i].set_xdata(self.iz_data[:,0]/self.time_divisors[self.time_unit.get()])
                self.lines[i].set_ydata(self.iz_data[:,j])
                self.lines[i].set_label(self.checkboxes[j-1].cget("text"))
                self.ax.set_xlabel('Time [{:s}]'.format(str(self.time_unit.get())))
                self.ax.set_xlim(0, np.max(self.iz_data[:,0]/self.time_divisors[self.time_unit.get()]))
                maximum = max(np.max(self.iz_data[:,j]), maximum)
                minimum = min(np.min(self.iz_data[:,j]), minimum)
                i+=1
            j+=1
        self.ax.set_ylim(minimum, maximum*1.1)
        if not self.ax.get_legend_handles_labels() == ([], []):
            self.ax.legend(loc='best')
        self.canvas.draw()

    def update_ydata(self):
        self.ax.cla()
        self.ax.set_ylabel('Tritium [kg]')
        count = sum([x.get() for x in self.plot_ints])
        self.ax.plot([]*count,[]*count)
        self.update_plot()

    def change_scale(self,*arg):
        xlims = list(self.ax.get_xlim())
        xlims[0] = xlims[0]*self.old_timescale/self.time_divisors[self.time_unit.get()]
        xlims[1] = xlims[1]*self.old_timescale/self.time_divisors[self.time_unit.get()]
        for line in self.lines:
            data = line.get_xdata()*self.old_timescale/self.time_divisors[self.time_unit.get()]
            line.set_xdata(data)
        self.old_timescale = self.time_divisors[self.time_unit.get()]
        self.ax.set_xlim(xlims)
        self.ax.set_xlabel('Time [{:s}]'.format(self.time_unit.get()))
        self.canvas.draw()
        self.ax.set_ylabel('Tritium [kg]')

    def cleanup(self):
        if self.first_run==False:
            if os.path.exists(self.tmpfile[:-2]+'_out.csv'):
                os.remove(self.tmpfile[:-2]+'_out.csv')
        if os.path.exists(self.tmpfile):
            os.remove(self.tmpfile)
parser = argparse.ArgumentParser(
        description='Graphical interface to run the fuel cycle example with different input parameters')
parser.add_argument('--test',help='for use in TMAP8 testing to verify successful script execution\
        No GUI will be shown when using this flag',action='store_true')
parsed_vals = parser.parse_args()
if parsed_vals.test==True:
    tk.Tk = fake_tk
    tk.Frame = fake_tk
    tk.Label = fake_tk
    tk.StringVar = fake_tk
    tk.Entry = fake_tk
    tk.Canvas = fake_tk
    tk.Button = fake_tk
    tk.Scrollbar = fake_tk
    ttk.Combobox = fake_tk
    tk.Checkbutton = fake_tk
    FigureCanvasTkAgg = fake_tk
    NavigationToolbar2Tk = fake_tk
    tk.IntVar = fake_tk
    window = fuel_cycle_form(headless=True)
    window.buttonClick()
    window.update_plot()
    window.plot_ints[0].set(1)
    window.update_plot()
    assert(window.test_compare()==True)
    #window.mainloop()
    window.destroy()
else:
    if __name__ == "__main__":
        window = fuel_cycle_form()
        icon_obj = PIL.ImageTk.PhotoImage(file=icon_path)
        window.wm_iconphoto(False,icon_obj)
        window.columnconfigure(0,weight=1)
        window.columnconfigure(1,weight=1)
        window.columnconfigure(2,weight=3)
        window.title("Tritium Inventory Plot")
        window.rowconfigure(1,weight=1)
        window.rowconfigure(2,weight=1)
        window.mainloop()
