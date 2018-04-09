insertImageViewModule = require "./insert-image-view"
electron = require 'electron'
fs = require 'fs'
isGif = require 'is-gif'

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
    e.preventDefault()
    if (e.metaKey && e.keyCode == 86 || e.ctrlKey && e.keyCode == 86)
      clipboard = require('clipboard')
      img = clipboard.readImage()
      ext = 'png'
      if img.isEmpty()
        potentialFilePath = clipboard.readText()
        ext = potentialFilePath.split('.').pop().toLowerCase()
        img = electron.nativeImage.createFromPath(potentialFilePath)
      if img.isEmpty()
        img = fs.readFileSync(potentialFilePath) # read Buffer from file
        if not isGif(img)
          return           # normaly return, paste whatever you want

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
          if img instanceof Buffer
            uploaderIns.upload(img, 'gif', callback) # only gif can be Buffer now
          else if new Set(['jpg', 'jpeg', 'jpe', 'jif', 'jfif', 'jfi']).has(ext)
            uploaderIns.upload(img.toJPEG(100), ext, callback)
          else
            uploaderIns.upload(img.toPNG(), ext, callback)

        insertImageViewInstance = new insertImageViewModule()
        insertImageViewInstance.display(uploadFn)
      catch e
        # add uploadName for trace uploader package error in feedback
        e.message += " [uploaderName=#{uploaderName}]"
        throw new Error(e)
