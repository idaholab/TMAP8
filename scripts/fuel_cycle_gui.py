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
import asyncio
import os
dir_path = os.path.dirname(os.path.realpath(__file__))
class fuel_cycle_form(tk.Tk):
    def __init__(self, interval=1/120):
        super().__init__()
        pattern = re.compile('\[(?P<variable>[0-9a-zA-Z_]+)\]\ntype = ConstantPostprocessor\nexecute_on = \'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR\'\nvalue\s?=\s*(?P<valnum>[0-9e.-]+)\n\[]',re.MULTILINE)
        instring = ''
        with open(os.path.join(dir_path,'..','test','tests','fuel-cycle','fuel_cycle.i'),'r') as infile:
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
        label = tk.Label(self, text='Variable')
        _,self.tmpfile = tempfile.mkstemp(suffix='.i')
        atexit.register(self.cleanup)
        label.grid(row=0,column=0)
        newlabel = tk.Label(self, text='Value')
        newlabel.grid(row=0,column=1)
        newlabel = tk.Label(self, text='Plot')
        newlabel.grid(row=0,column=2)
        output_var = tk.StringVar()
        self.plot_ints = []
        self.checkboxes = []
        self.first_run = True
        label = tk.Label(self, text="Initial storage")
        entryval = tk.StringVar()
        textwidget = tk.Entry(self,textvariable=entryval)
        entryval.set("225.4215")
        self.init_storage = textwidget
        labels.append(label)
        label.update()
        textwidget.update()
        label.grid(row=row_i, column=0)
        textwidget.grid(row=row_i, column=1)
        row_i+=1

        for match in self.matches:
            label = tk.Label(self, text=match[1][0])
            entryval = tk.StringVar()
            textwidget = tk.Entry(self, text=match[1][0],textvariable=entryval)
            entryval.set(match[1][1])
            self.entries.append(textwidget)
            labels.append(label)
            label.update()
            textwidget.update()
            label.grid(row=row_i, column=0)
            textwidget.grid(row=row_i, column=1)

            row_i+=1
        self.input_entries = self.entries
        plotlabel = tk.Label(self,text='Time Units')
        plotlabel.grid(row=row_i,column=0)
        self.time_unit = tk.StringVar()
        self.time_combobox = ttk.Combobox(self,width=20,textvariable=self.time_unit)
        self.time_combobox['values'] = ('seconds','hours','days','months','years')
        self.time_combobox.current(0)
        self.time_divisors = {'seconds':1,'minutes':scc.minute,'hours':scc.hour,'days':scc.day,'months':scc.year/12,'years':scc.year}
        self.old_timescale = self.time_divisors[self.time_unit.get()]
        self.time_unit.trace('w',self.change_scale)
        self.create_plot()
        self.update()
        self.entries.append(self.time_combobox)
        self.time_combobox.grid(row=row_i,column=1)
        row_i+=1
        self.labeldict = { label[1][0]:float(x.get()) for label, x in zip(self.matches, self.input_entries)}

        run_button = tk.Button(self,text="Run",command=self.buttonClick)
        run_button.grid(row=row_i,column=1)
        #test = self.apply_template(instring,self.matches,vals={x[1][0]:float(x[1][1]) for x in self.matches})

    def apply_template(self,vals):
        outstring = self.top_header
        pointer = 0
        outstring+='initial_condition = {:f}'.format(float(self.init_storage.get()))
        outstring+=self.bottom_header
        for match in self.matches:
            outstring+=self.filtstring[pointer:match[0][0]]
            outstring+='  [{:s}]\n    type = ConstantPostprocessor\n    execute_on = \'TIMESTEP_BEGIN INITIAL LINEAR NONLINEAR\'\n'.format(match[1][0])
            outstring+='    value = {:g}\n  []\n'.format(vals[match[1][0]])
            pointer = match[0][1]
        outstring+= self.filtstring[pointer:]
        outstring+=self.footer
        return outstring

    def create_plot(self):
        fig = Figure(figsize=(6,4), dpi=150)
        self.ax = fig.add_subplot(111)
        self.canvas = FigureCanvasTkAgg(fig, master=self)
        self.canvas._tkcanvas.grid(row=len(self.checkboxes)+11,column=2,rowspan=len(self.entries)+1 - len(self.checkboxes),columnspan=2)
        self.canvas.draw()

        self.toolbar = NavigationToolbar2Tk(self.canvas,self,pack_toolbar=False)
        self.toolbar.update()
        self.toolbar.grid(row=len(self.entries)+3,column=2,columnspan=2)
        self.canvas.mpl_connect("key_press_event", self.on_key_press)
        self.lines = self.ax.plot([],[])
        self.ax.set_xlabel('Time [{:s}]'.format(self.time_unit.get()))
        self.ax.set_ylabel('Tritium [kg]')
        self.ax.set_xlim(0,8.64e8/self.time_divisors[self.time_unit.get()])

    def on_key_press(self,event):
        key_press_handler(event,self.canvas,self.toolbar)

    def buttonClick(self):
        output_string = ""
        output_string = self.apply_template(self.labeldict)
        with open(self.tmpfile,'w') as outfile:
            outfile.write(output_string)
        self.proc = subprocess.Popen([os.path.join(dir_path,'..','tmap8-opt'), '-i',self.tmpfile],stdout=subprocess.PIPE,stderr=subprocess.PIPE,cwd=os.path.dirname(self.tmpfile))
        stdout, stderr = self.proc.communicate()
        with open(self.tmpfile[:-2]+'_out.csv','r') as infile:
            self.data_labels = infile.readline()[:-1].split(',')
            self.iz_data = np.genfromtxt(self.tmpfile[:-2]+'_out.csv',skip_header=1,delimiter=',')
        row_i=1
        self.ax.clear()
        if self.first_run:
            for label in self.data_labels[1:]:
                plotint = tk.IntVar()
                checkbutton = tk.Checkbutton(self,variable=plotint,onvalue=1,offvalue=0,command=self.update_ydata,text=label)
                self.checkboxes.append(checkbutton)
                self.plot_ints.append(plotint)
                checkbutton.grid(row=row_i, column=2)
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
                self.ax.set_xlabel('Time [{:s}]'.format(self.time_unit.get()))
                self.ax.set_xlim(0, np.max(self.iz_data[:,0]/self.time_divisors[self.time_unit.get()]))
                maximum = max(np.max(self.iz_data[:,j]), maximum)
                minimum = min(np.min(self.iz_data[:,j]), minimum)
                i+=1

            j+=1
        self.ax.set_ylim(minimum, maximum*1.1)
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


window = fuel_cycle_form()
window.title("Tritium Inventory Plot")
window.mainloop()
