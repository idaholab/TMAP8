# DETAILS: N. H. Snow Rev1
# Good luck to anyone who will attempt to edit or use this file.

from matplotlib import pyplot as plt; from matplotlib.colors import TABLEAU_COLORS as plt_colors
import pandas as pd; from pandas import DataFrame
import numpy as np; from numpy import ndarray
import typing; from typing import Union
import json
import os
from importlib import reload
from scipy import optimize; import scipy.stats as scipy
import seaborn
from IPython.display import HTML

plt = reload(plt)
plt.rcParams['font.family'] = 'Cambria'
plt.rcParams['font.size'] = 11
colors = list(plt_colors.values())

def json_serial_killer(an_obj, **kwargs):
    return_dict = {}
    try:
        if isinstance(an_obj, DataFrame):
           raise(AttributeError)
        else:
           obj_attributes = an_obj.__dict__
           for k, v in obj_attributes.items():
               return_dict[k] = json_serial_killer(v)
           return(return_dict)
    except(AttributeError):
        if isinstance(an_obj, dict):
            obj_attributes = an_obj
            for k, v in obj_attributes.items():
                return_dict[k] = json_serial_killer(v)
            return(return_dict)
        elif isinstance(an_obj, list):
            return_list = []
            for item in an_obj:
               return_list.append(json_serial_killer(item))
            return(return_list)
        elif isinstance(an_obj, ndarray):
            an_obj = an_obj.tolist()
            return_list = []
            for item in an_obj:
               return_list.append(json_serial_killer(item))
            return(return_list)
        elif isinstance(an_obj, (int, float, str)): 
            return(an_obj)
        elif isinstance(an_obj, DataFrame):
            return(an_obj.to_dict())

def read_json(path, **kwargs):
    with open(path, 'r') as ftw:
        my_json = json.load(ftw)
    return(my_json)

def call_inner_method(inner_obj, inner_method):
   return inner_obj.inner_method

def json_to_RESULTS(json_path = None, post_dictionary = None, **kwargs):
   json_dict = read_json(json_path) if not post_dictionary else post_dictionary
   json_results = RESULTS(empty=True)
   json_results.path = json_dict['path'] if 'path' in json_dict.keys() else None
   json_results.data_frame = json_dict['data_frame'] if 'data_frame' in json_dict.keys() else None
   json_results.data_vectors = json_dict['data_vectors'] if 'data_vectors' in json_dict.keys() else {}
   for vector,results in json_results.data_vectors.items():
      json_results.data_vectors[vector] = np.asarray(results)
   json_results.post_processing_vectors = json_dict['post_processing_vectors'] if 'post_processing_vectors' in json_dict.keys() else {}
   for post_vector, step_dict in json_results.post_processing_vectors.items():
      json_results.post_processing_vectors[post_vector] = {}
      for step, result_object in step_dict.items():
         json_results.post_processing_vectors[post_vector][step] = json_to_RESULTS(post_dictionary=result_object)
   return(json_results)
 
class RESULTS:
    def __init__(self, path: str = None, *args, empty: bool = False, **kwargs):
       self.path = path if not empty else None
       self.data_frame = pd.read_csv(path) if not empty else None
       self.data_vectors = {}
       self.post_processing_vectors = {}
       self.plots = {}
       return
    # Re-associates a csv (dataframe) with the results object
    def Reassociate(self, path: str = None):
       path = path if path else self.path
       self.data_frame = pd.read_csv(path)
       return()
    
    ################################################################################################################## Reading Data Methods #########
    # Reads vector from self's dataframe. Returns a numpy array.
    def read_vector(self, vector: str, *args) ->ndarray:
       data_vector = np.asarray(self.data_frame[vector].tolist())
       self.data_vectors[vector] = data_vector
       return(data_vector)
    
    # Reads multiple vectors, returns a dictionary of vectors and their ndarrays
    def read_vectors(self, vector_list: list[str], **kwargs) ->dict[str,ndarray]:
       vector_dict = {}
       for vector in vector_list:
         vector_dict[vector] = self.read_vector(vector)
       return()
    
    # Reads the results from VectorPostProcessors, expecting a directory containing the .csv files, using the naming convention set by MOOSE.
    def read_vector_post_processor_data(self, directory_path: str, post_processing_vector: str, *args, vector_list: list[str] = [], **kwargs)-> any:
        vector_post_processing_outputs = []
        for file in os.listdir(directory_path):
            if post_processing_vector in file: vector_post_processing_outputs.append(file)
        if vector_post_processing_outputs == []:
           return('No data available')
        self.post_processing_vectors[post_processing_vector] = {}
        for file in vector_post_processing_outputs:
            self.post_processing_vectors[post_processing_vector][(file[:-4].split('_'))[-1]] = RESULTS(os.path.join(directory_path, file))
            for vector in vector_list:
               self.post_processing_vectors[post_processing_vector][(file[:-4].split('_'))[-1]].read_vector(vector)
        return()
     
    # Save a vector or post_processor_vector as a json file. Vector must exist as a .data_vector entry in the RESULTS object or one of it's nested RESULTS objects.
    def save_vector(self, *args, path: str = '', vector: str = None, post_processor_vector: str = None, step: str = None, suppress_json: bool = False, **kwargs)-> Union[None, dict]:
       if post_processor_vector:
          saved_vector = self.post_processing_vectors[post_processor_vector][step].data_vectors[vector]
       else:
          saved_vector = self.data_vectors[vector]

       if post_processor_vector:
          vector = f'{post_processor_vector}_{step}_{vector}' # rename for output

       if suppress_json:
          return({'name':vector, 'data':saved_vector.tolist()})
       else:
          with open(f'{path}.json', 'w+') as ftw:
            ftw.write(json.dumps({'name':vector, 'data':saved_vector.tolist()}, indent=4))
       return()
    
    # Saving multiple vectors to the same json file.
    def save_vectors(self, path: str, *args, vector_list: list[str] = None, post_processor_vector_list: list[str] = [], step_list: list[str] = [], **kwargs)-> None:
       saved_dict = {}
       for vector in vector_list:
          if post_processor_vector_list:
            for post_vector in post_processor_vector_list:
               for step in step_list:
                  saved_dict[f'{post_vector}_{step}_{vector}'] = self.save_vector(vector = vector, post_processor_vector = post_vector,
                                                                                  step = step, suppress_json = True)
          else:
             saved_dict[vector] = self.save_vector(vector=vector, suppress_json=True)

       with open(f'{path}.json', 'w+') as ftw:
          ftw.write(json.dumps({'name':vector, 'data':saved_dict}, indent=4))
       return()
    
    # Save the results object, de-composing most or all attributes of the RESULTS object. Be wary of non-serializeable objects or data.
    def save_object(self, path: str, *args, do_not_print: list[str] = ['data_frame', 'plots'], suppress_save = False, **kwargs)-> str:
       do_not_print.append('post_processor_vectors')
       attributes = self.__dict__
       print_attributes = {}
       for k,v in attributes.items():
          if k not in do_not_print: 
            print_attributes[k] = v           
      
       post_processing_vectors_dict = {}
       for vector, step_dict in self.post_processing_vectors.items():
          post_processing_vectors_dict[vector] = {}
          for step, result in step_dict.items():
             post_processing_vectors_dict[vector][step] = result.save_object(path = '', *args, do_not_print = do_not_print, suppress_save = True)

       print_attributes['post_processing_vectors'] = post_processing_vectors_dict
       
       if suppress_save:
          return(print_attributes)
       else:
         with open(f'{path}.json', 'w+') as ftw:
             ftw.write(json.dumps(json_serial_killer(print_attributes), indent=4))
             print(f"Object attributes written to {path}.json as a json file.")
             return(print_attributes)
    
    ################################################################################################################## Manipulating Data Methods ####
    # Scales a vector given a user-defined factor, see also normalize_vector.
    def get_scaled_vector(self, vector: str, factor: float, *args, new_name: str = '', **kwargs)-> ndarray:
       new_vector = new_name if new_name else vector
       self.data_vectors[new_vector] = np.multiply(self.data_vectors[vector], factor)
       return(self.data_vectors[new_vector])
    
    # Normalize a vector according to its total or its maximum (default)
    def get_normalized_vector(self, vector: str, *args, by_total: bool = False, new_name: str = '', **kwargs)-> ndarray:
       un_normalized = self.data_vectors[vector]
       norm_factor = sum(un_normalized.tolist()) if by_total else max(un_normalized.tolist())
       normalized = np.divide(un_normalized, norm_factor)
       new_vector = new_name if new_name else f'{vector}_normalized'
       self.data_vectors[new_vector] = normalized
       return(normalized)
    
    # Integrates function to aquire cumulative value, 
    def get_cumulative_function(self, vector: str, *args, new_name: str = '', **kwargs)-> ndarray:
       root_function = self.data_vectors[vector].tolist()
       cumulative_function = [root_function[0]]
       for value in root_function[1:]:
          cumulative_function.append(value + cumulative_function[-1])
       new_vector = new_name if new_name else f'{vector}_cumulative'
       self.data_vectors[new_vector] = np.asarray(cumulative_function)
       return(cumulative_function)
    
    # Differentiates function to get spacing/difference e.g. time step if operating on time
    def get_differential_function(self, vector: str, *args, new_name: str = '', **kwargs)-> ndarray:
       new_vector = new_name if new_name else f'{vector}_differential'
       root_function = self.data_vectors[vector].tolist()
       differential_function = [root_function[0]]
       for i in range(1, len(root_function)):
          differential_function.append(root_function[i] - root_function[i-1])
       self.data_vectors[new_vector] = np.asarray(differential_function)
       return(differential_function)
    
    # Get the dot product between two vectors (scalar) or element wise multiplication (element_wise)
    def get_vector_dot_product(self, vector1: str, vector2: str, element_wise: bool = True, *args, new_name: str = '', **kwargs)-> Union[float, ndarray]:
       new_name = new_name if new_name else f'{vector1}_{vector2}_dot_product'
       func_1 = self.data_vectors[vector1]
       func_2 = self.data_vectors[vector2]
       dot_product = np.dot(func_1, func_2) if not element_wise else np.multiply(func_1, func_2)
       self.data_vectors[new_name] = dot_product
       return(dot_product)
    
    # Sums an arbitrary number of vectors
    def sum_vectors(self, vector_list: list[str], *args, new_name: str = '', **kwargs)-> ndarray:
       if new_name:
          new_vector = new_name
       else: 
          new_vector = 'sum_of'
          for i in vector_list:
            new_vector += f'_{i}' 
      
       summed_vector = self.data_vectors[vector_list[0]]
       for vector in vector_list[1:]:
          summed_vector = np.add(summed_vector, self.data_vectors[vector])
      
       self.data_vectors[new_vector] = summed_vector
       return(summed_vector)
    
    # Finds the closest point to a given value for a specified vector. Also returns the values of other corresponding vectors at that same index. Only valid for PostProcessors not VectorPostProcessors
    def get_closest_point(self, value: Union[float, int], vector: str, *args, corresponding_vectors: list[str] = [], **kwargs)-> dict[str, Union[float, int]]:
       my_vector = self.data_vectors[vector].tolist()
       distance = [np.abs(i-value) for i in my_vector]
       closest_index = distance.index(min(distance))
       closest = {'index':closest_index,
                  'value': my_vector[closest_index],
                  'corresponding_values' : [float(self.data_vectors[i][closest_index]) for i in corresponding_vectors]}
       return(closest)
    
    def manipulate_post_processor_data(self, post_processor_vector, *args, function = None,  **kwargs):
       #active_function = function
       for time_step, step_results in self.post_processing_vectors[post_processor_vector].items():
         results = function(step_results, *args)
       return()
    
    def apply_kernel(self, vector, function, *args, post_processing_vector = None, step = None, new_name = None, **kwargs):
       new_name = new_name if new_name else f"{vector}_{function}"
       if not post_processing_vector:
         result = function(self.data_vectors[vector], *args, **kwargs)
         self.data_vectors[new_name] = result
       else:
         result = function(self.post_processing_vectors[post_processing_vector][step].data_vectors[vector])
         self.post_processing_vectors[post_processing_vector][step].data_vectors[new_name] = result
       return(result)

    ################################################################################################################## Plotting Data Methods #########
    def show_plot(self, fig_to_show):
       plt.show(self.plots[fig_to_show])
       return()
    def clear_plot(self):
       plt.clf()
       return()
    
    def plot_time_series_vector(self, x, y, post_processing_vector,
                                xlabel = '', ylabel = '', title = '', xmin = 0, xmax = 0, ymin = 0, ymax = 0,xscale = 'linear', yscale = 'linear', display_rate = 0, **kwargs):
       xlabel = xlabel if xlabel else x; ylabel = ylabel if ylabel else y
       title = title if title else f'{xlabel} vs {ylabel}'
       plt.ion()
       fig, ax = plt.subplots(1,1, figsize=(6,4))
       ax.set_xlabel(xlabel); ax.set_ylabel(ylabel); ax.set_title(title)
       ax.set_xscale(xscale); ax.set_yscale(yscale)
       ax.set_facecolor('aliceblue'); ax.grid(visible = True, which = 'both', axis = 'both', color = 'gainsboro', linestyle = ':', )
       for time_step, step_result in self.post_processing_vectors[post_processing_vector].items():
          if time_step != '0000':
            ax.set_title(f'{title} at {np.round(self.data_vectors['time'][int(time_step)], 1)}s')
            xvector = step_result.data_vectors[x]*1000 # convert to mm
            yvector = step_result.data_vectors[y]
            if len(ax.get_lines())>4:
               (ax.get_lines())[0].remove()
            ax.plot(xvector, yvector, label = time_step, color = 'darkblue', linewidth = 1.5)
            plt.pause(display_rate)
       plt.show()
       ax.legend()
       plt.ioff()
       return()
    
    def plot_time_series_vectors(self, x, y_list, post_processing_vector,
                                xlabel = '', ylabels = [], titles = [], xmin = 0, xmax = 0, ymin = 0, ymax = 0,xscale = 'linear', yscale = 'linear', display_rate = 0, **kwargs):
       
       xlabel = xlabel if xlabel else x; 
       titles = titles if titles else [f'{xlabel} vs {ylabels[i]}' for i in range (0, len(y_list))]
       plt.ion()

       fig, ax = plt.subplots(len(y_list),1, figsize=(12,4))
       i = 0
       for y in y_list:
         ax[i].set_xlabel(xlabel); ax[i].set_ylabel(ylabels[i]); ax[i].set_title(titles[i])
         ax[i].set_xscale(xscale); ax[i].set_yscale(yscale)
         ax[i].set_facecolor('aliceblue'); ax[i].grid(visible = True, which = 'both', axis = 'both', color = 'gainsboro', linestyle = ':', )
         i += 1

       for time_step, step_result in self.post_processing_vectors[post_processing_vector].items():
          if time_step != '0000':
            i = 0
            xvector = step_result.data_vectors[x]*1000 # convert to mm
            for y in y_list:
               ax[i].set_title(f'{titles[i]} at {np.round(self.data_vectors['time'][int(time_step)], 1)}s')
               yvector = step_result.data_vectors[y]

               if len(ax[i].get_lines())>4:
                  (ax[i].get_lines())[0].remove()
               ax[i].plot(xvector, yvector, label = time_step, color = 'darkblue', linewidth = 1.5)
               i += 1

            plt.pause(display_rate)
       plt.show()
       for axes in ax:
         axes.legend()
       plt.ioff()
       return()
    
    def general_plot(self, x_list, y_list, figure_title = '', labels = [],post_processor_vector = None, step = None,
                     x_label = 'Abscissa', y_label = 'Ordinate(s)', x_min = None, x_max = None, y_min = None, y_max = None, x_scale = 'linear', yscale = 'linear',
                     marker = 'o', linewidth = 1.5 ):
       x_list = x_list if len(x_list)>1 else [x_list[0] for i in y_list]; labels = labels if labels else y_list; labels = labels if len(labels)>1 else [labels[0] for i in y_list]
       fig, ax = plt.subplots(1,1, figsize=(6,4))
       ax.set_xlabel(x_label); ax.set_ylabel(y_label); ax.set_xscale(x_scale); ax.set_yscale(yscale);ax.set_facecolor('aliceblue');ax.grid(visible = True, which = 'both', axis = 'both', color = 'gainsboro', linestyle = ':')
       ax.set_title(figure_title)

       for i in range(0, len(y_list)):
          if not post_processor_vector:
             ax.plot(self.data_vectors[x_list[i]], self.data_vectors[y_list[i]], label = labels[i], linewidth = 1.5)
          else:
             ax.plot(self.post_processing_vectors[post_processor_vector][step].data_vectors[x_list[i]],
                     self.post_processing_vectors[post_processor_vector][step].data_vectors[y_list[i]], label = labels[i], color = 'darkblue', linewidth = 1.5)
       
       ax.set_xlim(x_min, x_max)
       ax.set_ylim(y_min, y_max)
       ax.legend()
       return()
    
    def general_plot2(self, x, y, figure_name = '', post_processor_vector = None, step = None, clear_fig = True, operating_fig = None,
                     x_label = '', y_label = '', plot_label = '', marker = 'o', linewidth = 1.5,
                     x_min = 0, x_max = 0, y_min = 0, y_max = 0, x_scale = 'linear', y_scale = 'linear', **kwargs):
       if clear_fig:
         if figure_name:
             new_fig = plt.figure(num=figure_name, figsize = [6.0, 4.0], dpi = 300, facecolor = 'aliceblue', edgecolor='slategrey')  
         else:
             figure_name = str(len(self.plots.keys())+1)
             new_fig = plt.figure(num=figure_name, figsize = [6.0, 4.0], dpi = 300, facecolor = 'aliceblue', edgecolor='slategrey')
             new_axes = new_fig.add_axes(rect=(1,1,1,1), projection = 'rectilinear')
       else:
          plt.figure(self.plots[operating_fig])

       x_vector = self.data_vectors[x] if not post_processor_vector else self.post_processing_vectors[post_processor_vector][step].data_vectors[x]
       y_vector = self.data_vectors[y] if not post_processor_vector else self.post_processing_vectors[post_processor_vector][step].data_vectors[y]
       x_limits = [0,0]; x_limits[0] = x_min if x_min else min(x_vector); x_limits[1] = x_max if x_max else max(x_vector)
       y_limits = [0,0]; y_limits[0] = y_min if y_min else min(y_vector); y_limits[1] = y_max if y_max else max(y_vector)


       new_axes.xlabel = x_label if x_label else x; plt.ylabel = y_label if y_label else y; plt.xlim(x_limits); plt.ylim(y_limits)
       new_axes.xscale = x_scale; plt.yscale = y_scale
       plt.plot(x_vector,y_vector, label = plot_label, marker = marker, linewidth = linewidth)

       self.plots[figure_name] = new_fig
       return()
    
    def plot_vector(self, x, y, post_processor_vector = None, step = None,
                    xscale = 'linear',yscale = 'linear', x_units = '', y_units = '',
                    xlabel = None, ylabel = None, x_min = None, x_max = None, y_min = None, y_max = None):
       xlabel = xlabel if xlabel else x; ylabel = ylabel if ylabel else y
       x_vector = self.post_processing_vectors[post_processor_vector][step].data_vectors[x] if post_processor_vector else self.data_vectors[x]
       y_vector = self.post_processing_vectors[post_processor_vector][step].data_vectors[y] if post_processor_vector else self.data_vectors[y]

       assert len(x_vector) == len(y_vector)
       plt.plot(x_vector, y_vector)
       plt.xlabel(xlabel); plt.ylabel(ylabel); plt.title(f'{ylabel} vs {xlabel}'); plt.yscale(yscale); plt.xscale(xscale)
       #plt.xlim((0,1600))
       if x_max and x_min: 
          plt.xlim((x_min, x_max));print('HEY')
       else:
          print('huh')
       if x_max and not x_min: plt.xlim(right=x_max)
       if x_min and not x_max: plt.xlim(left=x_min)
       if y_max and y_min: 
          plt.ylim((y_min, y_max))
       if y_max and not y_min: plt.ylim(top=y_max)
       if y_min and not y_max: plt.ylim(bottom=y_min)
       my_axs = plt.gca()
       plt.show()

    def plot_arbitrary_number(self, x, y_list, post_processing_vector = None, plot_variable = None,
                              xscale = 'linear',yscale = 'linear', x_units = '', y_units = '',
                              xlabel = None, ylabel = None,
                              x_min = None, x_max = None, y_min = None, y_max = None, legend = False):
       xlabel = xlabel if xlabel else 'X'; ylabel = ylabel if ylabel else 'Y'
       x_vector = self.data_vectors[x]

       plt.xlabel(xlabel);plt.ylabel(ylabel);plt.title(f'{ylabel} vs {xlabel}');plt.yscale(yscale);plt.xscale(xscale)
       plt.grid(visible=True, which='both', axis='both', color='gainsboro')
       #plt.xlim((0,1600))
       if x_max and x_min: plt.xlim((x_min, x_max))
       #if x_max and not x_min: plt.xlim(right=x_max)
       #if x_min and not x_max: plt.xlim(left=x_min)
       if y_max and y_min: plt.ylim((y_min, y_max))
       #if y_max and not y_min: plt.ylim(top=y_max)
       #if y_min and not y_max: plt.ylim(bottom=y_min)
       for y in y_list:
         y_vector = self.post_processing_vectors[post_processing_vector][y][plot_variable] if post_processing_vector else self.data_vectors[y]
         plt.plot(x_vector, y_vector, label = y)
       my_axs = plt.gca()
       if legend: plt.legend()
       plt.show()

    def plot_vector_pairs(self, xy_list, post_processing_vector = None, plot_variable = None,
                          xscale = 'linear',yscale = 'linear', x_units = '', y_units = '',
                          xlabel = None, ylabel = None,
                          x_min = None, x_max = None, y_min = None, y_max = None, legend = False):
       xlabel = xlabel if xlabel else 'X'; ylabel = ylabel if ylabel else 'Y'

       #assert len(x_vector) == len(y_vector)
       plt.xlabel(xlabel);plt.ylabel(ylabel);plt.title(f'{ylabel} vs {xlabel}');plt.yscale(yscale);plt.xscale(xscale)
       #plt.xlim((0,1600))
       if x_max and x_min: plt.xlim((x_min, x_max))
       if x_max and not x_min: plt.xlim(right=x_max)
       if x_min and not x_max: plt.xlim(left=x_min)
       if y_max and y_min: plt.ylim((y_min, y_max))
       if y_max and not y_min: plt.ylim(top=y_max)
       if y_min and not y_max: plt.ylim(bottom=y_min)
       for xy in xy_list:
         x = xy[0]; y = xy[1]
         x_vector = self.post_processing_vectors[post_processing_vector][x].data_vectors[plot_variable] if post_processing_vector else self.data_vectors[x]
         y_vector = self.post_processing_vectors[post_processing_vector][y].data_vectors[plot_variable] if post_processing_vector else self.data_vectors[y]
         label = f'{y} vs {x}' if legend else None
         plt.plot(x_vector, y_vector, label = label)
       if legend:
         plt.legend()
       else:
         pass
       my_axs = plt.gca()
       plt.show()
          
class COMPARISON:
   def __init__(self, comp1, comp2, **kwargs):
      self.comp1 = RESULTS(comp1) if type(comp1) == str else comp1
      self.comp2 = RESULTS(comp2) if type(comp2) == str else comp2

      self.comparisons = {}
      self.shared = {}
      return
   
   def get_shared_vector(self, vector):
      self.shared[vector] = self.comp1.data_vectors[vector] if vector in self.comp1.data_vectors.keys() else self.comp2.data_vectors[vector]
      return(self.shared[vector])

   def abs_diff(self, vector):
      self.comp1.read_vector(vector)
      self.comp2.read_vector(vector)

      self.comparisons[f'{vector}_abs_diff'] = np.subtract(self.comp1.data_vectors[vector], self.comp2.data_vectors[vector])

      return(self.comparisons[f'{vector}_abs_diff'])
   
   def rel_diff_2to1(self, vector):
      self.comp1.read_vector(vector)
      self.comp2.read_vector(vector)

      self.comparisons[f'{vector}_rel_diff_2to1'] = np.divide(np.subtract(self.comp2.data_vectors[vector], self.comp1.data_vectors[vector]), self.comp1.data_vectors[vector])

      return(self.comparisons[f'{vector}_rel_diff_2to1'])
   
   def rel_diff_1to2(self, vector):
      self.comp1.read_vector(vector)
      self.comp2.read_vector(vector)

      self.comparisons[f'{vector}_rel_diff_1to2'] = np.divide(np.subtract(self.comp1.data_vectors[vector], self.comp2.data_vectors[vector]), self.comp2.data_vectors[vector])

      return(self.comparisons[f'{vector}_rel_diff_1to2'])
   
   def Save_Object(self, path):
       attributes = self.__dict__
       with open(f'{path}.json', 'w+') as ftw:
          ftw.write(json.dumps(attributes, indent=4))
       return(f"Object attributes written to {path}.json as a json file.")
   
   def plot_vector(self, result_obj, x, y):
       x_vector = result_obj.data_vectors[x]
       y_vector = result_obj.data_vectors[y]

       assert len(x_vector) == len(y_vector)
       plt.plot(x_vector, y_vector)
       plt.xlabel(x);plt.ylabel(y);plt.title(f'{y} vs {x}')
       my_axs = plt.gca()
       plt.show()

   def plot_comparison(self, x, y, shared_x = True, x_object = None):
       x_vector = x_object.data_vectors[x] if x_object else self.shared[x]
       y_vector = self.comparisons[y]

       assert len(x_vector) == len(y_vector)
       plt.plot(x_vector, y_vector)
       plt.xlabel(x);plt.ylabel(y);plt.title(f'{y} vs {x}')
       my_axs = plt.gca()
       plt.show()

   def plot_two(self, x, y):
      x1_vector = self.comp1.data_vectors[x]
      x2_vector = self.comp2.data_vectors[x]
      y1_vector = self.comp1.data_vectors[y]
      y2_vector = self.comp2.data_vectors[y]
      plt.plot(x1_vector, y1_vector, label = self.comp1.path)
      plt.plot(x2_vector, y2_vector, label = self.comp2.path)
      plt.xlabel(x);plt.ylabel(y);plt.title(f'{y} vs {x}')
      plt.legend()
      plt.show()
      return()
      
   def general_plot(self, x_list_1, y_list_1, x_list_2, y_list_2, figure_title = '', labels_1 = [], labels_2 = [], post_processor_vector = None, step = None,
                    x_label = 'Abscissa', y_label = 'Ordinate(s)', x_min = 0, x_max = 0, y_min = 0, y_max = 0, x_scale = 'linear', yscale = 'linear',
                    marker = 'o', linewidth = 1.5 ):
       
       x_list_1 = x_list_1 if len(x_list_1)>1 else [x_list_1[0] for i in y_list_1]; labels_1 = labels_1 if labels_1 else y_list_1; labels_1 = labels_1 if len(labels_1)>1 else [labels_1[0] for i in y_list_1]
       x_list_2 = x_list_2 if len(x_list_2)>1 else [x_list_2[0] for i in y_list_2]; labels_2 = labels_2 if labels_2 else y_list_2; labels_2 = labels_2 if len(labels_2)>1 else [labels_2[0] for i in y_list_2]

       fig, ax = plt.subplots(1,1, figsize=(6,4))
       ax.set_xlabel(x_label); ax.set_ylabel(y_label); ax.set_xscale(x_scale); ax.set_yscale(yscale);ax.set_facecolor('aliceblue');ax.grid(visible = True, which = 'both', axis = 'both', color = 'gainsboro', linestyle = ':')
       ax.set_title(figure_title)
       for i in range(0, len(y_list_1)):
          if not post_processor_vector:
             ax.plot(self.comp1.data_vectors[x_list_1[i]], self.comp1.data_vectors[y_list_1[i]], label = labels_1[i], linewidth = 1.5)
          else:
             ax.plot(self.comp1.post_processing_vectors[post_processor_vector][step].data_vectors[x_list_1[i]],
                     self.comp1.post_processing_vectors[post_processor_vector][step].data_vectors[y_list_1[i]],
                     label = labels_1[i], color = 'darkblue', linewidth = 1.5)
       for i in range(0, len(y_list_2)):
          if not post_processor_vector:
             ax.plot(self.comp2.data_vectors[x_list_2[i]], self.comp2.data_vectors[y_list_2[i]], label = labels_2[i], linewidth = 1.5)
          else:
             ax.plot(self.comp2.post_processing_vectors[post_processor_vector][step].data_vectors[x_list_2[i]],
                     self.comp2.post_processing_vectors[post_processor_vector][step].data_vectors[y_list_2[i]],
                     label = labels_2[i], color = 'darkblue', linewidth = 1.5)
             
       ax.legend()
       return()

class SOBOL:
   def __init__(self, path, inputs = [], time_step = 0):
      #['Heat Flux','Tritium Flux', 'Coolant Temperature', 'Coolant Tritium Concentration']
      self.time_step = time_step
      self.reference_dict = read_json(path)
      self.path = path 
      
      if inputs and inputs != []:
         self.inputs = inputs
      else:
         inputs = []
         for key in self.reference_dict["time_steps"][self.time_step].keys():
            if "matrix/" in key: inputs.append(f"{key.split('/')[-2]}/{key.split('/')[-1]}")#;print(inputs[-1])
         self.inputs = inputs

      if inputs == []:
         for key in self.reference_dict["time_steps"][self.time_step]["matrix"].keys():
            if "results" not in key: inputs.append(key)#; print(key)
         self.inputs = inputs
      
      self.sobol = {'confidence_intervals': self.reference_dict['reporters']['sobol']['confidence_intervals']['levels'],
                    'number_of_samples': self.reference_dict['reporters']['sobol']['confidence_intervals']['replicates'],
                    'inputs': inputs,
                    'number_of_inputs': self.reference_dict['reporters']['sobol']['num_params'],
                    'outputs': [(i.split(':'))[-2] for i in self.reference_dict['reporters']['sobol']['values'].keys()],
                    'number_of_outputs': len(self.reference_dict['reporters']['sobol']['values'].keys())}
      self.statistics = {'confidence_intervals': self.reference_dict['reporters']['sobol']['confidence_intervals']['levels'],
                         'number_of_samples': self.reference_dict['reporters']['sobol']['confidence_intervals']['replicates'],
                         'inputs': inputs,
                         'number_of_inputs': len(inputs),
                         'outputs': [],
                         'number_of_outputs': len(self.reference_dict['reporters']['stats'].keys())}
      stat_outs = []
      for key in self.reference_dict['time_steps'][0]['stats'].keys():
         out = key.split(':')
         #print(out);v=input('Continue?')
         out = out[-2]
         if out not in stat_outs: stat_outs.append(out)
      self.statistics['outputs'] = stat_outs
      return
   
   def get_sobol_1st(self):
      keys = self.sobol['confidence_intervals']
      sobol_first = {}

      for output in self.sobol['outputs']:
         sobol_first[output] = {}
        
         sobol_first[output]['mean'] = {} 
         j = 0
         for inp in self.sobol['inputs']:
            sobol_first[output]['mean'][inp] = self.reference_dict["time_steps"][self.time_step]["sobol"][f"results_results:{output}:value"]["FIRST_ORDER"][0][j]
            j +=1
         i = 0
         for key in keys:
            j = 0
            sobol_first[output][key] = {}
            for inp in self.sobol['inputs']:
               sobol_first[output][key][inp] = self.reference_dict["time_steps"][self.time_step]["sobol"][f"results_results:{output}:value"]["FIRST_ORDER"][1][i][j]
               j +=1
            i += 1
      
      sobol_first_df = {}
      for output in self.sobol['outputs']:
          sobol_first_df[output] = pd.DataFrame(sobol_first[output])

      self.sobol['FIRST_ORDER'] = sobol_first_df
      return(sobol_first_df)
   
   def get_sobol_2nd(self):
      keys = self.sobol['confidence_intervals']
      sobol_scd = {}
      for output in self.sobol['outputs']:
         sobol_scd[output] = {'mean':{}}

         j = 0
         for inp in self.inputs:
            sobol_scd[output]['mean'][inp] = self.reference_dict["time_steps"][self.time_step]["sobol"][f"results_results:{output}:value"]["SECOND_ORDER"][0][j]
            j += 1

         i = 0
         for key in keys:
            sobol_scd[output][key] = {}
            j = 0
            for inp in self.inputs:
               sobol_scd[output][key][inp] = self.reference_dict["time_steps"][self.time_step]["sobol"][f"results_results:{output}:value"]["SECOND_ORDER"][1][i][j]
               j += 1
            i += 1
      
      sobol_scd_df = {}
      for output in self.sobol['outputs']:
         sobol_scd_df[output] = pd.DataFrame(sobol_scd[output])
      
      self.sobol['SECOND_ORDER'] = sobol_scd_df
      return(sobol_scd_df)
   
   def get_sobol_total(self):
      keys = self.sobol['confidence_intervals']
      sobol_tot = {}

      for output in self.sobol['outputs']:
         sobol_tot[output] = {}
        
         sobol_tot[output]['mean'] = {} 
         j = 0
         for inp in self.sobol['inputs']:
            sobol_tot[output]['mean'][inp] = self.reference_dict["time_steps"][self.time_step]["sobol"][f"results_results:{output}:value"]["TOTAL"][0][j]
            j +=1
         i = 0
         for key in keys:
            j = 0
            sobol_tot[output][key] = {}
            for inp in self.sobol['inputs']:
               sobol_tot[output][key][inp] = self.reference_dict["time_steps"][self.time_step]["sobol"][f"results_results:{output}:value"]["TOTAL"][1][i][j]
               j +=1
            i += 1
      
      sobol_tot_df = {}
      for output in self.sobol['outputs']:
          sobol_tot_df[output] = pd.DataFrame(sobol_tot[output])

      self.sobol['TOTAL'] = sobol_tot_df
      return(sobol_tot_df)
   
   def get_var_accounted_for(self):
      if 'SECOND_ORDER' not in self.sobol.keys():
         self.get_sobol_2nd()
      
      self.sobol['var_accounted_for'] = {}
      for output in self.sobol['outputs']:
         var_acc_for = 0

         for col in self.reference_dict["time_steps"][0]["sobol"][f"results_results:{output}:value"]["SECOND_ORDER"][0]:
            for row in col:
               var_acc_for += row

         self.sobol['var_accounted_for'][output] = var_acc_for
      return(self.sobol['var_accounted_for'])
   
   def get_statistics(self):
      self.statistics['statistics'] = {}
      for output in self.statistics['outputs']:
         self.statistics['statistics'][output] = {'value':{}, 'stddev':{}}
         self.statistics['statistics'][output]['value']['mean'] = self.reference_dict['time_steps'][self.time_step]['stats'][f"results_results:{output}:value_MEAN"][0]
         self.statistics['statistics'][output]['stddev']['mean'] = self.reference_dict['time_steps'][self.time_step]['stats'][f"results_results:{output}:value_STDDEV"][0]
         i = 0
         for ci in self.statistics['confidence_intervals']:
            self.statistics['statistics'][output]['value'][ci] = self.reference_dict['time_steps'][self.time_step]['stats'][f"results_results:{output}:value_MEAN"][1][i]
            self.statistics['statistics'][output]['stddev'][ci] = self.reference_dict['time_steps'][self.time_step]['stats'][f"results_results:{output}:value_STDDEV"][1][i]
            i += 1

      for output in self.statistics['outputs']:
         self.statistics['statistics'][output] = pd.DataFrame(self.statistics['statistics'][output])

      return(self.statistics['statistics'])

   def get_matrix(self):
      matrix = {'inputs':{}, 'outputs': {}}
      # First, establish inputs and outputs
      inputs = self.inputs
      outputs = self.sobol['outputs']
      # Second, extract input matrix, store as dataframe
      inp_matrix = {}
      for inp in inputs:
         try:
            inp_matrix[inp] = self.reference_dict["time_steps"][self.time_step][f"matrix/{inp}"]["value"]
         except:
            try:
               inp_matrix[inp] = self.reference_dict["time_steps"][self.time_step]["matrix"][inp]
            except:
               print(f"Could not find {inp} matrix for {self.path}")
      
      # Third, extract output matricies for each output, store as dictionary of {output: dataframe}
      outp_matrix = {}
      for outp in outputs:
         outp_matrix[outp] = self.reference_dict["time_steps"][self.time_step]["matrix"][f"matrix_results:{outp}:value"]

      # package as attribute
      self.matrix = {"inputs": pd.DataFrame(inp_matrix), "outputs": pd.DataFrame(outp_matrix)}
      return(self.matrix)
   
   def save_object(self, path: str, *args, do_not_print: list[str] = [], suppress_save = False, **kwargs)-> str:
       attributes = self.__dict__
       print_attributes = {}
       for k,v in attributes.items():
          if k not in do_not_print: 
            print_attributes[k] = v           

       if suppress_save:
          return(print_attributes)
       else:
         with open(f'{path}.json', 'w+') as ftw:
             ftw.write(json.dumps(json_serial_killer(print_attributes), indent=4))
             print(f"Object attributes written to {path}.json as a json file.")
             return(print_attributes)
   
   def estimate_state_frequency(self, state_limit, output, use_matrix = True, method = 'gamma', pdf=False, plot = True, normalize = True, factor = 'min', function=None):
      if use_matrix:
         print(f"Using a frequency approach based on <{self.statistics['number_of_samples']}> samples.")
         total_samples = len(self.matrix['outputs'][output])
         exceeding_samples = 0
         for i in self.matrix['outputs'][output]:
            exceeding_samples += 1 if i > state_limit else 0

         frequency = exceeding_samples/total_samples
         print(frequency)
         return(frequency)

      else:
         print(f"Fitting data to a {method} probability distribution.")
         data = np.asarray(self.matrix["outputs"][output])
         if normalize:
            minima = np.min(data); mean = np.mean(data); median = np.median(data)
            if method == 'mean':
               data = np.divide(np.subtract(data, mean), mean)
               state_limit = (state_limit - mean)/mean
            elif method == 'min':
               data = np.divide(np.subtract(data, minima), minima)
               state_limit = (state_limit - minima)/minima
            elif method == 'median':
               data = np.divide(np.subtract(data, median), median)
               state_limit = (state_limit - minima)/minima
         frequency = 0

         if method == 'gamma':
            curve_args = scipy.gamma.fit(data)  
            if pdf and plot:
               self.plot_histogram(labels=[output], plot = [output], normalize = normalize, density=True, factor=factor)
               plt.plot(np.linspace(min(data)-50, max(data)+50, num=len(data)), scipy.gamma.pdf(np.linspace(min(data)-50, max(data)+50, num=len(data)), *curve_args))
            elif plot:
               self.plot_percentiles(labels=[output], plot = [output], normalize = normalize, flip = True)
               plt.plot(np.linspace(min(data), max(data), num=len(data)), scipy.gamma.cdf(np.linspace(min(data), max(data), num=len(data)), *curve_args))
            frequency = scipy.gamma.sf(state_limit, *curve_args)
            chi_squared, p_value = scipy.chisquare(scipy.relfreq(data, numbins=int(0.01*len(data)))[0],
                                                   scipy.relfreq(scipy.gamma.pdf(np.linspace(min(data), max(data), num=len(data)), *curve_args), numbins=int(0.01*len(data)))[0], axis=0)
            print(f'Chi-squared: {chi_squared}\nP-value: {p_value} ({p_value-1})')
            

         elif method == 'normal':
            curve_args = scipy.norm.fit(data)
            if pdf and plot:
               self.plot_histogram(labels=[output], plot = [output], normalize = normalize, density=True, factor=factor)
               plt.plot(np.linspace(min(data), max(data), num=len(data)), scipy.norm.pdf(np.linspace(min(data), max(data), num=len(data)), *curve_args))
            elif plot:
               self.plot_percentiles(labels=[output], plot = [output], normalize = normalize, flip = True)
               plt.plot(np.linspace(min(data), max(data), num=len(data)), scipy.norm.cdf(np.linspace(min(data), max(data), num=len(data)), *curve_args))
            frequency = scipy.norm.sf(state_limit, *curve_args)
            chi_squared, p_value = scipy.chisquare(scipy.relfreq(data, numbins=int(0.01*len(data)))[0],
                                                   scipy.relfreq(scipy.norm.pdf(np.linspace(min(data), max(data), num=len(data)), *curve_args), numbins=int(0.01*len(data)))[0], axis=0)
            print(f'Chi-squared: {chi_squared}\nP-value: {p_value} ({p_value-1})')

         elif method == 'lognormal':
            curve_args = scipy.lognorm.fit(data)
            if pdf and plot:
               self.plot_histogram(labels=[output], plot = [output], normalize = normalize, density=True, factor=factor)
               plt.plot(np.linspace(min(data), max(data)), scipy.lognorm.pdf(np.linspace(min(data), max(data)), *curve_args))
            elif plot:
               self.plot_percentiles(labels=[output], plot = [output], normalize = normalize, flip = True)
               plt.plot(np.linspace(min(data), max(data)), scipy.lognorm.cdf(np.linspace(min(data), max(data)), *curve_args))
            frequency = scipy.lognorm.sf(state_limit, *curve_args)
            chi_squared, p_value = scipy.chisquare(scipy.relfreq(data, numbins=int(0.01*len(data)))[0],
                                                   scipy.relfreq(scipy.lognorm.pdf(np.linspace(min(data), max(data), num=len(data)), *curve_args), numbins=int(0.01*len(data)))[0], axis=0)
            print(f'Chi-squared: {chi_squared}\nP-value: {p_value} ({p_value-1})')

         elif method == 'beta':
            curve_args = scipy.beta.fit(data)
            if pdf and plot:
               self.plot_histogram(labels=[output], plot = [output], normalize = normalize, density=True, factor=factor)
               plt.plot(np.linspace(min(data), max(data)), scipy.beta.pdf(np.linspace(min(data), max(data)), *curve_args))
            elif plot:
               self.plot_percentiles(labels=[output], plot = [output], normalize = normalize, flip = True)
               plt.plot(np.linspace(min(data), max(data)), scipy.beta.cdf(np.linspace(min(data), max(data)), *curve_args))
            frequency = scipy.beta.sf(state_limit, *curve_args)
            chi_squared, p_value = scipy.chisquare(scipy.relfreq(data, numbins=int(0.01*len(data)))[0],
                                                   scipy.relfreq(scipy.beta.pdf(np.linspace(min(data), max(data), num=len(data)), *curve_args), numbins=int(0.01*len(data)))[0], axis=0)
            print(f'Chi-squared: {chi_squared}\nP-value: {p_value} ({p_value-1})')
         
         elif method == 'tukeylambda':
            curve_args = scipy.tukeylambda.fit(data)
            if pdf and plot:
               self.plot_histogram(labels=[output], plot = [output], normalize = False, density=True, factor=factor)
               plt.plot(np.linspace(min(data), max(data)), scipy.tukeylambda.pdf(np.linspace(min(data), max(data)), *curve_args))
            elif plot:
               self.plot_percentiles(labels=[output], plot = [output], normalize = False, flip = True)
               plt.plot(np.linspace(min(data), max(data)), scipy.tukeylambda.cdf(np.linspace(min(data), max(data)), *curve_args))
            frequency = scipy.tukeylambda.sf(state_limit, *curve_args)
            chi_squared, p_value = scipy.chisquare(scipy.relfreq(data, numbins=int(0.01*len(data)))[0],
                                                   scipy.relfreq(scipy.tukeylambda.pdf(np.linspace(min(data), max(data), num=len(data)), *curve_args), numbins=int(0.01*len(data)))[0], axis=0)
            print(f'Chi-squared: {chi_squared}\nP-value: {p_value} ({p_value-1})')

         elif method == 'power':
            curve_args = scipy.powerlaw.fit(data)
            if pdf and plot:
               self.plot_histogram(labels=[output], plot = [output], normalize = False, density=True, factor=factor)
               plt.plot(np.linspace(min(data), max(data)), scipy.powerlaw.pdf(np.linspace(min(data), max(data)), *curve_args))
            elif plot:
               self.plot_percentiles(labels=[output], plot = [output], normalize = False, flip = True)
               plt.plot(np.linspace(min(data), max(data)), scipy.powerlaw.cdf(np.linspace(min(data), max(data)), *curve_args))
            frequency = scipy.powerlaw.sf(state_limit, *curve_args)
            chi_squared, p_value = scipy.chisquare(scipy.relfreq(data, numbins=int(0.01*len(data)))[0],
                                                   scipy.relfreq(scipy.powerlaw.pdf(np.linspace(min(data), max(data), num=len(data)), *curve_args), numbins=int(0.01*len(data)))[0], axis=0)
            print(f'Chi-squared: {chi_squared}\nP-value: {p_value} ({p_value-1})')
         
         elif method == 'exponential':
            curve_args = scipy.expon.fit(data)
            if pdf and plot:
               self.plot_histogram(labels=[output], plot = [output], normalize = False, density=True, factor=factor)
               plt.plot(np.linspace(min(data), max(data)), scipy.expon.pdf(np.linspace(min(data), max(data)), *curve_args))
            elif plot:
               self.plot_percentiles(labels=[output], plot = [output], normalize = False, flip = True)
               plt.plot(np.linspace(min(data), max(data)), scipy.expon.cdf(np.linspace(min(data), max(data)), *curve_args))
            frequency = scipy.expon.sf(state_limit, *curve_args)
            chi_squared, p_value = scipy.chisquare(scipy.relfreq(data, numbins=int(0.01*len(data)))[0],
                                                   scipy.relfreq(scipy.expon.pdf(np.linspace(min(data), max(data), num=len(data)), *curve_args), numbins=int(0.01*len(data)))[0], axis=0)
            print(f'Chi-squared: {chi_squared}\nP-value: {p_value} ({p_value-1})')

         elif method == 'halfcauchy':
            curve_args = scipy.halfcauchy.fit(data)
            if pdf and plot:
               self.plot_histogram(labels=[output], plot = [output], normalize = False, density=True, factor=factor)
               plt.plot(np.linspace(min(data), max(data)), scipy.halfcauchy.pdf(np.linspace(min(data), max(data)), *curve_args))
            elif plot:
               self.plot_percentiles(labels=[output], plot = [output], normalize = False, flip = True)
               plt.plot(np.linspace(min(data), max(data)), scipy.halfcauchy.cdf(np.linspace(min(data), max(data)), *curve_args))
            frequency = scipy.halfcauchy.sf(state_limit, *curve_args)
            chi_squared, p_value = scipy.chisquare(scipy.relfreq(data, numbins=int(0.01*len(data)))[0],
                                                   scipy.relfreq(scipy.halfcauchy.pdf(np.linspace(min(data), max(data), num=len(data)), *curve_args), numbins=int(0.01*len(data)))[0], axis=0)
            print(f'Chi-squared: {chi_squared}\nP-value: {p_value} ({p_value-1})')

         elif method == 'general':
            curve_args = function.fit(data)
            if pdf and plot:
               self.plot_histogram(labels=[output], plot = [output], normalize = False, density=True, factor=factor)
               plt.plot(np.linspace(min(data), max(data)), function.pdf(np.linspace(min(data), max(data)), *curve_args))
            elif plot:
               self.plot_percentiles(labels=[output], plot = [output], normalize = False, flip = True)
               plt.plot(np.linspace(min(data), max(data)), function.cdf(np.linspace(min(data), max(data)), *curve_args))
            frequency = function.sf(state_limit, *curve_args)
            chi_squared, p_value = scipy.chisquare(scipy.relfreq(data, numbins=int(0.01*len(data)))[0],
                                                   scipy.relfreq(function.pdf(np.linspace(min(data), max(data), num=len(data)), *curve_args), numbins=int(0.01*len(data)))[0], axis=0)
            print(f'Chi-squared: {chi_squared}\nP-value: {p_value} ({p_value-1})')

         print(f"Frequency: {frequency}")
         return(frequency, curve_args)
   
   def plot_percentiles(self, labels = [], plot = [], flip = False, normalize = True, factor = 'mean',
                        xlabel = None, ylabel = None, pdf= False):
      # Next: formulate dictionary of {output: {percentiles: [], values: []}}
      plot = plot if plot else self.statistics['outputs']
      xlabel = 'Percentile' if not xlabel else xlabel; ylabel = 'Normalized Value' if not ylabel else ylabel
      flip = True if pdf else flip
      plotting_dict = {}
      means = {}
      for output in plot:
         means[output] = list(self.statistics['statistics'][output]['value'])[0]
         plotting_dict[output] = {'percentiles': self.statistics['confidence_intervals'],
                                   'values': list(self.statistics['statistics'][output]['value'])[1:]}
      # First: normalize confidence intervals with respect to the mean
      for k, v in plotting_dict.items():
         #mean = plotting_dict[k]['values'][0]
         if normalize: 
            plotting_dict[k]['values'] = [i/means[k] for i in v['values']]
      # Plot all using lineplot, markers, and legend
      fig, ax = plt.subplots(1,1, figsize = (6,4))
      ax.set_title('Cumulative Distributions'); ax.set_xlabel(xlabel); ax.set_ylabel(ylabel)
      ax.set_facecolor('aliceblue');ax.grid(visible = True, which = 'both', axis = 'both', color = 'gainsboro', linestyle = ':')
      markers = [',','.','o','^','v','<','>','s','o','P','+','x','D']
      i = 0
      for label, data in plotting_dict.items():
         if flip:
            percentiles = data['percentiles'] if not pdf else [0] + [(data['percentiles'][i]-data['percentiles'][i-1])/(data['values'][i]-data['values'][i-1]) for i in range(1, len(data['percentiles']))]
            plotting_dict[label]['percentiles'] = percentiles
            ax.plot(data['values'], percentiles, label = label, marker = markers[i])
            ax.set_xlabel('Normalized Value'); ax.set_ylabel('Percentile')
         else:
            ax.plot(data['percentiles'], data['values'], label = label, marker = markers[i])
         i += 1
      if labels:
         ax.legend(labels = labels, loc = 'upper center', ncols = 3, fontsize = 'small', bbox_to_anchor = (0.5, -0.15))
      else:
         ax.legend(loc = 'upper center', ncols = 3, fontsize = 'small', bbox_to_anchor = (0.5, -0.15))
      return(plotting_dict)
   
   def plot_histogram(self, labels = [], plot = [], density=False, normalize = True, factor = 'mean',
                      xlabel = None, ylabel = None, plot_inp=False):
      if plot_inp:
         plot = list(self.matrix['inputs'].columns) if not plot else plot
      else:
         plot = plot if plot else list(self.matrix["outputs"].columns)
      
      labels = labels if labels else plot
      ylabel = 'Frequency' if not ylabel else ylabel
      histogram_dict = {}

      for outp in plot:
         histogram_dict[outp] = list(self.matrix["inputs"][outp]) if plot_inp else list(self.matrix["outputs"][outp]) 
         if normalize:
            if factor == 'mean':
               xlabel = '(X-Mean)/Mean' if not xlabel else xlabel
               mean = np.mean(histogram_dict[outp]) 
               histogram_dict[outp] = [(i/mean - 1) for i in histogram_dict[outp]]
            elif factor == 'min':
               xlabel = '(X-Min)/Min' if not xlabel else xlabel
               minima = np.min(histogram_dict[outp])
               histogram_dict[outp] = [((i-minima)/minima) for i in histogram_dict[outp]]
            elif factor == 'median':
               xlabel = '(X-Median)/Median' if not xlabel else xlabel
               median = np.median(histogram_dict[outp])
               histogram_dict[outp] = [((i-median)/median) for i in histogram_dict[outp]]

      fig, ax = plt.subplots(1,1, figsize = (6,4))
      ax.set_title('Histogram Distributions'); ax.set_xlabel(xlabel); ax.set_ylabel(ylabel)
      ax.set_facecolor('aliceblue');ax.grid(visible = True, which = 'both', axis = 'both', color = 'gainsboro', linestyle = ':')
      
      for outp, hist in histogram_dict.items():
         ax.hist(hist, fill=False, histtype="step", stacked=True, label=outp, bins=int(len(hist)/100), density = density)
      if labels:
         ax.legend(labels = labels, loc = 'upper center', ncols = 3, fontsize = 'small', bbox_to_anchor = (0.5, -0.15))
      else:
         ax.legend(loc = 'upper center', ncols = 3, fontsize = 'small', bbox_to_anchor = (0.5, -0.15))
      return()
   
   def plot_violin(self, labels = [], plot = [], normalize = True, factor = 'mean',
                   ylabel = None, xlabel = None):
      plot = plot if plot else self.matrix["outputs"]
      labels = labels if labels else list(self.matrix['outputs'].index)
      ylabel = '(X-Mean)/Mean' if not ylabel else ylabel
      vio_dict = {}

      for outp in plot:
         vio_dict[outp] = list(self.matrix["outputs"][outp])
         if normalize:
            if factor == 'mean':
               xlabel = '(X-Mean)/Mean' if not xlabel else xlabel
               mean = np.mean(vio_dict[outp]) 
               vio_dict[outp] = [(i/mean - 1) for i in vio_dict[outp]]
            elif factor == 'min':
               xlabel = '(X-Min)/Min' if not xlabel else xlabel
               minima = np.min(vio_dict[outp])
               vio_dict[outp] = [((i-minima)/minima) for i in vio_dict[outp]]
            elif factor == 'median':
               xlabel = '(X-Median)/Median' if not xlabel else xlabel
               median = np.median(vio_dict[outp])
               vio_dict[outp] = [((i-median)/median) for i in vio_dict[outp]]

      fig, ax = plt.subplots(1,1, figsize = (6,4))
      ax.set_title('Output Distributions'); ax.set_ylabel(ylabel)
      ax.set_facecolor('aliceblue');ax.grid(visible = True, which = 'both', axis = 'both', color = 'gainsboro', linestyle = ':')
      
      positions = [i+1 for i in range(0, len(vio_dict.keys()))]
      viola = ax.violinplot(vio_dict.values(), positions, showmeans=True, showextrema=True)

      i = 0
      for part in viola['bodies']:
         part.set_facecolor(colors[i]); part.set_edgecolor('black')
         i += 1

      if labels:
         ax.legend(labels = labels, loc = 'upper center', ncols = 3, fontsize = 'small', bbox_to_anchor = (0.5, -0.15))
      else:
         ax.legend(loc = 'upper center', ncols = 3, fontsize = 'small', bbox_to_anchor = (0.5, -0.15))
      return()

   def plot_sobol(self, outp = '', order = 'FIRST_ORDER', inp_labels = ['Mobile T Flux', 'Cool. T Conc.','Heat Flux','Cool. Temp.'],
                   outp_labels=['H3 Permeation','H3 FLux', 'Coo. Heat Flux','Cu Max T','CCZ Max T','W Max T','H3 Retention'],
                   lci = 0.05, uci = 0.95):
      
      fig, ax = plt.subplots(len(self.inputs),1, figsize = (8,8))
      ax[0].set_title(f'{order} Sensitivity Indicies')
      x = [j+1 for j in range(0, len(self.sobol['outputs']))]
      
      i = 0
      for inp in self.inputs:
         ax[i].set_ylabel(f'{inp_labels[i]}');#ax[i].set_ylim(-0.25,1.25)
         ax[i].set_facecolor('aliceblue');ax[i].grid(visible = True, which = 'both', axis = 'both', color = 'gainsboro', linestyle = ':')

         y = np.asarray([self.sobol[order][outp]['mean'][inp]  for outp in self.sobol['outputs']]); #print(y)
         n_err = np.asarray([self.sobol[order][outp][lci][inp] for outp in self.sobol['outputs']]); n_err = np.abs(np.subtract(n_err, y))
         p_err = np.asarray([self.sobol[order][outp][uci][inp] for outp in self.sobol['outputs']]); p_err = np.abs(np.subtract(p_err, y))

         ax[i].errorbar(x, y, yerr = [n_err, p_err], linewidth=0, elinewidth=1, marker='o')
         i += 1
         
        # if i == 1:
        #    for j in range(0, len(self.sobol['outputs'])): 
        #       print(f"{y[j]}:{n_err[j]}:{p_err[j]}")


      x_string = ''
      k = 1
      for j in outp_labels:
         x_string += f"{k} = {j}\n"
         k += 1
      ax[-1].set_xlabel(x_string, loc='left')
      #print(self.sobol[order].keys())
      return()
   
   def sobol_heat_map(self, outp  = 'max_temperature_CuCrZr', outp_label = 'Tritium Permeation',
                     xlabels = ['Tritium Flux','Coolant Tritium \nConcentration','Heat Flux','Coolant Temperature'],
                     ylabels = ['Tritium Flux','Coolant Tritium \nConcentration','Heat Flux','Coolant Temperature']):
      # Construct new dataframe
      new_df = {}
      operating_df = self.sobol['SECOND_ORDER'][outp]; rows = list(operating_df.index)
      for row in rows:
         new_df[row] = {}
         i = 0
         for subrow in rows:
            new_df[row][subrow] = operating_df['mean'][row][i]
            i += 1
      new_df = pd.DataFrame(new_df)
      seaborn.heatmap(new_df, cmap='bwr', xticklabels=xlabels, yticklabels=ylabels, label=outp_label, annot=True, vmin=-1.0, vmax=2.0)
      return(new_df)
   
   def confidence_interval_heatmap(self, order = 'FIRST_ORDER', outp  = 'max_temperature_CuCrZr', outp_label = 'CCZ Maximum Temperature',
                                 xlabels = ['Tritium Flux','Coolant Tritium \nConcentration','Heat Flux','Coolant Temperature'],
                                 min_cf = 0.05, max_cf = 0.95, heatmap = True, title = None):
      # Construct new dataframe
      ylabels = [min_cf, 'mean', max_cf]; title = title if title else outp_label
      new_df = {}
      operating_df = self.sobol[order][outp]; rows = list(operating_df.index)
      for row in rows:
         new_df[row] = {min_cf: operating_df[min_cf][row], 'Mean': operating_df['mean'][row], max_cf: operating_df[max_cf][row]}
      new_df = pd.DataFrame(new_df)
      if heatmap:
         seaborn.heatmap(new_df, cmap='bwr', xticklabels=xlabels, yticklabels=ylabels, label=outp_label, annot=True)
      else:
         styler = new_df.style \
            .format(precision=3)
         #new_df
      return(new_df)
   
   def confidence_interval_table(self, outp = 'max_temperature_CuCrZr', outp_label = 'CCZ Maximum Temperature',
                                 xlabels = ['Tritium Flux','Coolant Tritium \nConcentration','Heat Flux','Coolant Temperature'],
                                 min_cf = 0.05, max_cf = 0.95, precision = 2):
      xlabels = xlabels if xlabels else self.inputs
      col_dict = {}
      for k in range(0, len(self.inputs)):
         col_dict[self.inputs[k]] = xlabels[k]

      df = {}
      for inp in self.inputs:
         df[inp] = {}
         for n_inp in range(0, len(self.inputs)):
            df[inp][n_inp] =''
            df[inp][n_inp] += f"{np.round(self.sobol["SECOND_ORDER"][outp]["mean"][inp][n_inp], precision)} "
            df[inp][n_inp] += f"({np.round(self.sobol["SECOND_ORDER"][outp][min_cf][inp][n_inp], precision)},"
            df[inp][n_inp] += f"{np.round(self.sobol["SECOND_ORDER"][outp][max_cf][inp][n_inp], precision)})"
      df = pd.DataFrame(df)
      df.style.background_gradient(cmap=seaborn.light_palette("blue", as_cmap=True))
      df.style.set_caption(f"{outp} Sensitivity Indicies")
      df.style.set_properties(**{'text-align': 'center'})
      df.index = xlabels; df.rename(columns=col_dict, inplace=True)

      HTML(df.to_html(index=False))
      return(df.style)

   def plot_inp_out(self, outp, inp, xlabel = None, ylabel = None, curve_fit_function = lambda x, a, b: a +b*x, guess_args = [0.0, 1.0]):
      xlabel = inp if not xlabel else xlabel; ylabel = outp if not ylabel else ylabel; 

      fig, ax = plt.subplots(1,1, figsize = (6,4))
      ax.set_title(f'{ylabel} vs {xlabel}'); ax.set_ylabel(ylabel); ax.set_xlabel(xlabel)
      ax.set_facecolor('aliceblue');ax.grid(visible = True, which = 'both', axis = 'both', color = 'gainsboro', linestyle = ':')

      x_vector = self.matrix['inputs'][inp]
      y_vector = self.matrix['outputs'][outp]
      ax.scatter(x_vector, y_vector, marker='o')

      if curve_fit_function:
         fit_args, pcov = optimize.curve_fit(curve_fit_function, x_vector, y_vector, p0 = guess_args)
         print(f"Optimized parameters: {fit_args}")
         y_pred = curve_fit_function(x_vector, *fit_args)

         ss_tot = np.sum((y_vector - np.mean(y_vector))**2)
         ss_res = np.sum((y_vector - y_pred)**2)
         r_sqr = 1 - ss_res/ss_tot

         print(f"R2: {r_sqr}")

      return()

def Polynomial_Kernel(vector, *args, **kwargs):
   i = 0
   poly_vector = np.zeros(vector.shape)
   for arg in args:
       poly_vector += np.multiply(arg, np.power(vector, i))
       i += 1
   return(poly_vector)

def Exponential_Kernel(vector, *args, pre_exponential_factor = 0, frequency = 0, power = -1, **kwargs):
   exponential_vector = pre_exponential_factor*np.exp((frequency*np.power(vector, power)))
   return(exponential_vector)

do_these = ['coolant_heat_flux', 'max_temperature_Cu','max_temperature_CuCrZr', 'max_temperature_W', 'total_retention']
labels = ["Coolant Heat Flux","Cu Max T","CCZ Max T","W Max T", "Total Retention"]
A1 = SOBOL("Sobol Studies/Accident 1 Sobol/Accident_1_Sobol_out_v2.json")
A2 = SOBOL("Sobol Studies/Accident 2 Sobol/Accident_2_Sobol_out_v2.json")
SS = SOBOL("Sobol Studies/Steady Sobol v1/Sobol_v4_out.json")
A1.get_matrix(); A2.get_matrix(); SS.get_matrix()
A1.get_sobol_1st(); A2.get_sobol_1st(); SS.get_sobol_1st()
A1.get_sobol_2nd(); A2.get_sobol_2nd(); SS.get_sobol_2nd()
A2.get_sobol_total(); A2.get_sobol_total(); SS.get_sobol_total()
A1.get_statistics(), A2.get_statistics(); SS.get_statistics()

###S4 = SOBOL("Sobol_v4_out.json")
###S4.get_matrix();S4.get_sobol_1st();S4.get_sobol_2nd();S4.get_sobol_total();S4.get_statistics();S4.get_var_accounted_for()
#S4.plot_sobol(outp='F_permeation')
#S4.sobol_heat_map()
#  ["Permeation","Tritium Exit Flux","Coolant Heat Flux","Cu Max T","CCZ Max T","W Max T", "Total Retention"]
#  ['F_permeation','Scaled_Tritium_Flux','coolant_heat_flux', 'max_temperature_Cu','max_temperature_CuCrZr', 'max_temperature_W', 'total_retention']

#S4.plot_percentiles(labels=do_these, plot=do_these, flip=True)
#S4.plot_histogram(labels=do_these, plot=do_these)
#S4.plot_violin(labels=labels, plot=do_these)
#S4.estimate_state_frequency(623.15, 'max_temperature_CuCrZr')
#sob = SOBOL('Sobol_out.json')
#sob.get_statistics()
#print(sob.plot_percentiles(labels = ['Permeation','Coolant Tritium Flux','Coolant Heat Flux',
#                                     'Cu Max T','CCZ Max T','W Max T','Total Retention']))

##fnsf = json_to_RESULTS('FNSF_results_4.json')
##fnsf.plot_time_series_vectors('y',['temperature','C_total'],'line',
##                              display_rate=0.0001, xlabel = "Distance from Coolant Center [mm]", ylabels = ['Temperature','Tritium Concentration [g/m3]'], titles = ['FNSF Divertor Monoblock', ''])
#
# path_to_home = '../../../../'
# nominal_divertor = pd.read_csv(path_to_home+'Downloads/DIVMON_TEST_out_line_2747.csv')
# ss_divertor = pd.read_csv(path_to_home+'Downloads/convergence_testing_out_line_0521.csv')

# nominal_centerline_temperature = np.asarray(nominal_divertor['temperature'].to_list())
# steady_state_centerline_temperature = np.asarray(ss_divertor['temperature'].to_list())

# centerline_temperature_difference = np.subtract(nominal_centerline_temperature, steady_state_centerline_temperature)

# nominal_flux = np.asarray(nominal_divertor['flux_y'].to_list())
# steady_flux = np.asarray(ss_divertor['flux_y'].to_list())


# centerline_flux_difference = np.divide(np.subtract(nominal_flux, steady_flux), nominal_flux)

# plt.plot()