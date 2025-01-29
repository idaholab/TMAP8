import mms

def run():
    df1 = mms.run_spatial('mms.i', 4, y_pp=['L2u'])
    fig = mms.ConvergencePlot(xlabel=r'$\Delta$t', ylabel='$L_2$ Error')
    fig.plot(df1, label=['L2u'], marker='o', markersize=8, num_fitted_points=3, slope_precision=1)
    fig.save('mms_spatial.png')
    return fig

if __name__ == '__main__':
    run()
