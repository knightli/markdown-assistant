insertImageViewModule = require "./insert-image-view"

module.exports =
  config:
    uploader:
      title: "uploader"
      type: 'string'
      description: "uploader plugin for upload file"
      default: "qiniu-uploader"
    disableImageUploaderIfNotMarkdown:
      title: "disable image uploader if not markdown"
      type: "boolean"
      default: false

  activate: (state) ->
    console.log('markdown assistant activate')
    @attachEvent()

  attachEvent: ->
    workspaceElement = atom.views.getView(atom.workspace)
    workspaceElement.addEventListener 'keydown', (e) =>
      editor = atom.workspace.getActiveTextEditor()

      if atom.config.get('markdown-assistant.disableImageUploaderIfNotMarkdown')
        editor?.observeGrammar (grammar) =>
          return unless grammar
          return unless grammar.scopeName is 'source.gfm'
          @eventHandler e
      else
        @eventHandler e

  eventHandler: (e) ->
    console.log("metaKey ?" + e.metaKey)
    console.log("Is key equl 86,which is v? :" + e.keyCode)
    console.log("crtlKey ? " + e.ctrlKey)
    if (e.metaKey && e.keyCode == 86 || e.ctrlKey && e.keyCode == 86)
      console.log("I am going to get clipboard")
      clipboard = require('clipboard')
      img = clipboard.readImage()
      console.log("Is image empty?" + img.isEmpty())
      return if img.isEmpty()

      # insert loading text
      uploaderName = atom.config.get('markdown-assistant.uploader')
      uploaderPkg = atom.packages.getLoadedPackage(uploaderName)

      if not uploaderPkg
        atom.notifications.addWarning('markdown-assistant: uploader not found',{
          detail: "package \"#{uploaderName}\" not found!" +
            "\nHow to Fix:" +
            "\ninstall this package OR change uploader in markdown-assistant's settings"
        })
        return

      uploader = uploaderPkg?.mainModule
      if not uploader
        uploader = require(uploaderPkg.path)

      try
        uploaderIns = uploader.instance()

        uploadFn = (callback)->
          uploaderIns.upload(img.toPng(), 'png', callback)

        insertImageViewInstance = new insertImageViewModule()
        insertImageViewInstance.display(uploadFn)
      catch e
        # add uploadName for trace uploader package error in feedback
        e.message += " [uploaderName=#{uploaderName}]"
        throw new Error(e)
