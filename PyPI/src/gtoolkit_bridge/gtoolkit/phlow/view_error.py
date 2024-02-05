from .view import View


class ErrorView(View):
    def __init__(self):
        super().__init__()
        self.title("Error")
        self.errorMessage = "Error"

    def errorMessage(self):
        return self.errorMessage

    def set_errorMessage(self, error_msg):
        self.errorMessage = error_msg
        return self

    def asDictionaryForExport(self):
        exportData = super().asDictionaryForExport()
        exportData["viewName"] = "GtPhlowViewErrorViewSpecification"
        exportData["dataTransport"] = 1
        exportData["errorMessage"] = self.errorMessage
        return exportData
