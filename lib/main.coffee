{CompositeDisposable} = require 'atom'
NativeImage = require('native-image')
insertImageViewModule = require "./insert-image-view"

supportedScopes = new Set ['source.gfm', 'text.plain.null-grammar']

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

  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    #console.log('markdown assistant activate')
    @attachEvent()

  attachEvent: ->
    self = @

    # Handle File Drop Event
    @subscriptions.add atom.workspace.observeTextEditors (editor) ->
      textEditorElement = atom.views.getView editor
      textEditorElement.addEventListener 'drop', (e) ->
        return unless self.isUploadValid(editor)

        files = e.dataTransfer.files
        for f in (files[i] for i in [0...files.length]) when f.type.match "image/.*"
          do (f) ->
            e.preventDefault?()
            e.stopPropagation?()
            self.uploadImage(NativeImage.createFromPath(f.path))

    # Handle Clipboard Paste Event
    workspaceElement = atom.views.getView(atom.workspace)
    workspaceElement.addEventListener 'keydown', (e) =>
      editor = atom.workspace.getActiveTextEditor()
      return unless @isUploadValid(editor)
      if (e.metaKey && e.keyCode == 86)
        clipboard = require('clipboard')
        img = clipboard.readImage()
        @uploadImage(img)

  isUploadValid: (editor) ->
    if atom.config.get('markdown-assistant.disableImageUploaderIfNotMarkdown')
      return if editor and supportedScopes.has editor.getRootScopeDescriptor().getScopesArray()[0]
    else
      return true

  uploadImage: (nativeImage) ->
    return if nativeImage.isEmpty()
    buffer = nativeImage.toPng()

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
        uploaderIns.upload(buffer, 'png', callback)

      insertImageViewInstance = new insertImageViewModule()
      insertImageViewInstance.display(uploadFn)
    catch e
      # add uploadName for trace uploader package error in feedback
      e.message += " [uploaderName=#{uploaderName}]"
      throw new Error(e)

  deactivate: ->
    @subscriptions.dispose()
