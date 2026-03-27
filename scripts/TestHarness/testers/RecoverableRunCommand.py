from RunCommand import RunCommand


class RecoverableRunCommand(RunCommand):
    @staticmethod
    def validParams():
        params = RunCommand.validParams()
        return params

    def getCommand(self, options):
        # In --recover mode, TestHarness creates a "_part1" clone with skip_checks=True
        # and the original test as the follow-on recover job. Make the synthetic part1
        # a no-op so the user command executes only once after all prereqs have finished.
        if options.enable_recover and self.specs["skip_checks"]:
            return "true"

        return super().getCommand(options)
