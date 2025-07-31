# DETAILS: N. H. Snow Rev1
# Good luck to anyone who will attempt to edit or use this file.

from matplotlib import pyplot as plt; from matplotlib.colors import TABLEAU_COLORS as plt_colors
import pandas as pd; from pandas import DataFrame
import numpy as np; from numpy import ndarray
import json
from scipy import optimize; import scipy.stats as scipy
import seaborn

plt.rcParams['font.family'] = 'Cambria'
plt.rcParams['font.size'] = 8
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

class SOBOL:
   def __init__(self, path, inputs = [], time_step = 0, matrix_reporter_name = 'matrix', sobol_reporter_name = 'sobol', statistics_reporter_name = 'stats', results_transfer_name = 'results'):
      self.time_step = time_step
      self.reference_dict = read_json(path)
      self.path = path
      self.matrix_reporter = matrix_reporter_name
      self.sobol_reporter = sobol_reporter_name
      self.statistics_reporter = statistics_reporter_name
      self.results_transfer = results_transfer_name

      if inputs and inputs != []:
         self.inputs = inputs
      else:
         inputs = []
         for key in self.reference_dict["time_steps"][self.time_step].keys():
            if f"{matrix_reporter_name}/" in key: inputs.append(f"{key.split('/')[-2]}/{key.split('/')[-1]}")
         self.inputs = inputs

      if inputs == []:
         for key in self.reference_dict["time_steps"][self.time_step][matrix_reporter_name].keys():
            if "results" not in key: inputs.append(key)
         self.inputs = inputs

      self.sobol = {'confidence_intervals': self.reference_dict['reporters'][sobol_reporter_name]['confidence_intervals']['levels'],
                    'number_of_samples': self.reference_dict['reporters'][sobol_reporter_name]['confidence_intervals']['replicates'],
                    'inputs': inputs,
                    'number_of_inputs': self.reference_dict['reporters'][sobol_reporter_name]['num_params'],
                    'outputs': [(i.split(':'))[-2] for i in self.reference_dict['reporters'][sobol_reporter_name]['values'].keys()],
                    'number_of_outputs': len(self.reference_dict['reporters'][sobol_reporter_name]['values'].keys())}
      self.statistics = {'confidence_intervals': self.reference_dict['reporters'][sobol_reporter_name]['confidence_intervals']['levels'],
                         'number_of_samples': self.reference_dict['reporters'][sobol_reporter_name]['confidence_intervals']['replicates'],
                         'inputs': inputs,
                         'number_of_inputs': len(inputs),
                         'outputs': [],
                         'number_of_outputs': len(self.reference_dict['reporters'][statistics_reporter_name].keys())}
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
            sobol_first[output]['mean'][inp] = self.reference_dict["time_steps"][self.time_step][self.sobol_reporter][f"{self.results_transfer}_results:{output}:value"]["FIRST_ORDER"][0][j]
            j +=1
         i = 0
         for key in keys:
            j = 0
            sobol_first[output][key] = {}
            for inp in self.sobol['inputs']:
               sobol_first[output][key][inp] = self.reference_dict["time_steps"][self.time_step][self.sobol_reporter][f"{self.results_transfer}_results:{output}:value"]["FIRST_ORDER"][1][i][j]
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
            sobol_scd[output]['mean'][inp] = self.reference_dict["time_steps"][self.time_step][self.sobol_reporter][f"{self.results_transfer}_results:{output}:value"]["SECOND_ORDER"][0][j]
            j += 1

         i = 0
         for key in keys:
            sobol_scd[output][key] = {}
            j = 0
            for inp in self.inputs:
               sobol_scd[output][key][inp] = self.reference_dict["time_steps"][self.time_step][self.sobol_reporter][f"{self.results_transfer}_results:{output}:value"]["SECOND_ORDER"][1][i][j]
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
            sobol_tot[output]['mean'][inp] = self.reference_dict["time_steps"][self.time_step][self.sobol_reporter][f"{self.results_transfer}_results:{output}:value"]["TOTAL"][0][j]
            j +=1
         i = 0
         for key in keys:
            j = 0
            sobol_tot[output][key] = {}
            for inp in self.sobol['inputs']:
               sobol_tot[output][key][inp] = self.reference_dict["time_steps"][self.time_step][self.sobol_reporter][f"{self.results_transfer}_results:{output}:value"]["TOTAL"][1][i][j]
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
         self.statistics['statistics'][output]['value']['mean'] =  self.reference_dict['time_steps'][self.time_step][self.statistics_reporter][f"{self.results_transfer}_results:{output}:value_MEAN"][0]
         self.statistics['statistics'][output]['stddev']['mean'] = self.reference_dict['time_steps'][self.time_step][self.statistics_reporter][f"{self.results_transfer}_results:{output}:value_STDDEV"][0]
         i = 0
         for ci in self.statistics['confidence_intervals']:
            self.statistics['statistics'][output]['value'][ci] =  self.reference_dict['time_steps'][self.time_step][self.statistics_reporter][f"{self.results_transfer}_results:{output}:value_MEAN"][1][i]
            self.statistics['statistics'][output]['stddev'][ci] = self.reference_dict['time_steps'][self.time_step][self.statistics_reporter][f"{self.results_transfer}_results:{output}:value_STDDEV"][1][i]
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
            inp_matrix[inp] = self.reference_dict["time_steps"][self.time_step][f"{self.matrix_reporter}/{inp}"]["value"]
         except:
            try:
               inp_matrix[inp] = self.reference_dict["time_steps"][self.time_step][self.matrix_reporter][inp]
            except:
               print(f"Could not find {inp} matrix for {self.path}")

      # Third, extract output matricies for each output, store as dictionary of {output: dataframe}
      outp_matrix = {}
      for outp in outputs:
         outp_matrix[outp] = self.reference_dict["time_steps"][self.time_step][self.matrix_reporter][f"{self.matrix_reporter}_results:{outp}:value"]

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

   def estimate_state_frequency(self, state_limit, output, use_matrix = True, method = 'general', pdf=False, plot = True, normalize = True, factor = 'min', function=None,
                                 path = '', dpi =300, save_fig = False):
      path = path if path else f"frequency_of_{state_limit}_for{output}_by_{"matrix" if use_matrix else function}.png"
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
         print(f"Fitting data to a {function} probability distribution.")
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

         if method == 'general':
            curve_args = function.fit(data)
            if pdf and plot:
               fig, ax = self.plot_histogram(labels=[output], plot = [output], normalize = False, density=True, factor=factor)
               ax.plot(np.linspace(min(data), max(data)), function.pdf(np.linspace(min(data), max(data)), *curve_args))
            elif plot:
               fig, ax = self.plot_percentiles(labels=[output], plot = [output], normalize = False, flip = True)
               ax.plot(np.linspace(min(data), max(data)), function.cdf(np.linspace(min(data), max(data)), *curve_args))
            frequency = function.sf(state_limit, *curve_args)
            chi_squared, p_value = scipy.chisquare(scipy.relfreq(data, numbins=int(0.01*len(data)))[0],
                                                   scipy.relfreq(function.pdf(np.linspace(min(data), max(data), num=len(data)), *curve_args), numbins=int(0.01*len(data)))[0], axis=0)
            #print(f'Chi-squared: {chi_squared}\nP-value: {p_value} ({p_value-1})')
            if save_fig: fig.savefig(path, dpi=dpi)

         print(f"Frequency: {frequency}")
         return(frequency, curve_args)

   def plot_percentiles(self, labels = [], plot = [], flip = False, normalize = True, factor = 'mean',
                        xlabel = None, ylabel = None, pdf= False, path = '', dpi = 300, save_fig = False):
      # Next: formulate dictionary of {output: {percentiles: [], values: []}}
      plot = plot if plot else self.statistics['outputs']
      xlabel = 'Percentile' if not xlabel else xlabel; ylabel = 'Normalized Value' if not ylabel else ylabel
      flip = True if pdf else flip
      path = path if path else f"{plot}_percentiles.png"
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

      if save_fig: fig.savefig(path, dpi=dpi)
      return(plotting_dict, (fig,ax))

   def plot_histogram(self, labels = [], plot = [], density=False, normalize = True, factor = 'mean',
                      xlabel = None, ylabel = None, plot_inp=False, path = '', dpi = 300, save_fig = False):
      path = path if path else f"{plot}_histogram.png"
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

      if save_fig: fig.savefig(path, dpi=dpi)
      return((fig,ax))

   def plot_violin(self, labels = [], plot = [], normalize = True, factor = 'mean',
                   ylabel = None, xlabel = None, path = '', dpi = 300, save_fig = False):
      plot = plot if plot else self.matrix["outputs"]
      labels = labels if labels else list(self.matrix['outputs'].index)
      ylabel = '(X-Mean)/Mean' if not ylabel else ylabel
      path = path if path else f"{plot}_violin_plot.png"
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

      if save_fig: fig.savefig(path, dpi=dpi)
      return()

   def plot_sobol(self, outp = '', order = 'FIRST_ORDER', inp_labels = ['Mobile T Flux', 'Cool. T Conc.','Heat Flux','Cool. Temp.'],
                   outp_labels=['H3 Permeation','H3 FLux', 'Coo. Heat Flux','Cu Max T','CCZ Max T','W Max T','H3 Retention'],
                   lci = 0.05, uci = 0.95, path = '', dpi = 300, save_fig = False):
      path = path if path else f"{order}_sensitivity_indicies.png"
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
         x_string += f"{k} = {j}     "
         if k % 4 == 0:
            x_string += '\n'
         k += 1
      ax[-1].set_xlabel(x_string, loc='left')
      #print(self.sobol[order].keys())
      if save_fig: fig.savefig(path, dpi=dpi)
      return()

   def sobol_heat_map(self, outp  = 'max_temperature_CuCrZr', outp_label = 'Tritium Permeation',
                     xlabels = ['Tritium Flux','Coolant Tritium \nConcentration','Heat Flux','Coolant Temperature'],
                     ylabels = ['Tritium Flux','Coolant Tritium \nConcentration','Heat Flux','Coolant Temperature'],
                     path = '', dpi = 300, save_fig = False):
      # Construct new dataframe
      path = path if path else f"sobol_2ND_ORDER_{outp}_heatmap.png"
      new_df = {}
      operating_df = self.sobol['SECOND_ORDER'][outp]; rows = list(operating_df.index)
      for row in rows:
         new_df[row] = {}
         i = 0
         for subrow in rows:
            new_df[row][subrow] = operating_df['mean'][row][i]
            i += 1
      new_df = pd.DataFrame(new_df)
      axes = seaborn.heatmap(new_df, cmap='bwr', xticklabels=xlabels, yticklabels=ylabels, label=outp_label, annot=True, vmin=-1.0, vmax=2.0)
      if save_fig:
        figure = axes.get_figure(); figure.savefig(path, dpi=dpi)
      return(new_df)

   def confidence_interval_heatmap(self, order = 'FIRST_ORDER', outp  = 'max_temperature_CuCrZr', outp_label = 'CCZ Maximum Temperature',
                                 xlabels = ['Tritium Flux','Coolant Tritium \nConcentration','Heat Flux','Coolant Temperature'],
                                 min_cf = 0.05, max_cf = 0.95, heatmap = True, title = None, path = '', dpi = 200, save_fig = False):
      # Construct new dataframe
      ylabels = [min_cf, 'mean', max_cf]; title = title if title else outp_label
      path = path if path else f"{order}_{outp}_heatmap.png"
      new_df = {}
      operating_df = self.sobol[order][outp]; rows = list(operating_df.index)
      for row in rows:
         new_df[row] = {min_cf: operating_df[min_cf][row], 'Mean': operating_df['mean'][row], max_cf: operating_df[max_cf][row]}
      new_df = pd.DataFrame(new_df)
      if heatmap:
         axes = seaborn.heatmap(new_df, cmap='bwr', xticklabels=xlabels, yticklabels=ylabels, label=outp_label, annot=True)
         if save_fig:
            figure = axes.get_figure(); figure.savefig(path, dpi=dpi)
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
      return(df)

   def plot_inp_out(self, outp, inp, xlabel = None, ylabel = None, curve_fit_function = lambda x, a, b: a +b*x, guess_args = [0.0, 1.0], path = '', dpi = 300, save_fig = False):
      xlabel = inp if not xlabel else xlabel; ylabel = outp if not ylabel else ylabel
      path = path if path else f"{outp}_vs_{inp}.png"

      fig, ax = plt.subplots(1,1, figsize = (6,4))
      ax.set_title(f'{ylabel} vs {xlabel}'); ax.set_ylabel(ylabel); ax.set_xlabel(xlabel)
      ax.set_facecolor('aliceblue');ax.grid(visible = True, which = 'both', axis = 'both', color = 'gainsboro', linestyle = ':')

      x_vector = self.matrix['inputs'][inp]
      y_vector = self.matrix['outputs'][outp]
      ax.scatter(x_vector, y_vector, marker='o')

      if curve_fit_function:
         fit_args, pcov = optimize.curve_fit(curve_fit_function, x_vector, y_vector, p0 = guess_args)
         #print(f"Optimized parameters: {fit_args}")
         y_pred = curve_fit_function(x_vector, *fit_args)

         ss_tot = np.sum((y_vector - np.mean(y_vector))**2)
         ss_res = np.sum((y_vector - y_pred)**2)
         r_sqr = 1 - ss_res/ss_tot

         #print(f"R2: {r_sqr}")
      if save_fig: fig.savefig(path, dpi=dpi)
      return()

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
