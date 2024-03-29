!template load file=app_scs.md.template app=TMAP8App category=tmap8

## Clang Format

!style halign=left
Like MOOSE, TMAP8 uses `clang-format` with a customized
[config file](https://github.com/idaholab/tmap8/blob/devel/.clang-format)
for code formatting. If you have clang installed, you can run

```
git clang-format [<branch>]
```

to automatically format code changed between your currently checked-out branch
and `<branch>` (if left out, it defaults to the `HEAD` commit). If you don't do
this before submitting your code, don't worry! The continuous integration
testing system, [CIVET](https://civet.inl.gov), that is triggered when
you submit a pull request will check your code and provide information on the
changes needed to conform to the code style (if any).

TMAP8 development adheres to the software coding standard of the MOOSE Framework as described in [the MOOSE standard](sqa/framework_scs.md).
