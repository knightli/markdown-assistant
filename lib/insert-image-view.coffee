{$, View, TextEditorView} = require "atom-space-pen-views"
utils = require "./utils"

module.exports =
class InsertImageView extends View

  previouslyFocusedElement: null

  @content: ->
    @div class: "markdown-assistant-dialog", =>
      @label "Insert Image", class: "icon icon-device-camera"
      @div class: "loading-layer", outlet: "loadingLayer", =>
        @span class: "loading loading-spinner-tiny inline-block"
        @label "uploading...", class: "message"
      @div outlet: "imageInfoLayer", =>
        @div =>
          @label "Image Path (src)", class: "message"
          @subview "imageEditor", new TextEditorView(mini: true)
          @div outlet: "outputMessage", class: "text-info"
          @label "Title (alt)", class: "message"
          @subview "titleEditor", new TextEditorView(mini: true)
        @div class: "image-container", =>
          @img outlet: 'imagePreview'

  initialize: ->
    @imageEditor.on "blur", => @displayImagePreview(@imageEditor.getText().trim())
    @imageEditor.on "keyup", => @displayImagePreview(@imageEditor.getText().trim())

    atom.commands.add @element,
      "core:confirm": => @onConfirm()
      "core:cancel":  => @detach()

  onConfirm: ->
    imgUrl = @imageEditor.getText().trim()
    return unless imgUrl

    @insertImage();
    @detach()

  insertImage: ->
    imgurl = @imageEditor.getText().trim()
    title = @titleEditor.getText().trim()
    text = "![#{title}](#{imgurl})"
    @editor.setTextInBufferRange(@range, text)

  detach: ->
    return unless @panel.isVisible()
    @panel.hide()
    @previouslyFocusedElement?.focus()
    super

  display: (uploadFn) ->
    @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
    @previouslyFocusedElement = $(document.activeElement)
    @editor = atom.workspace.getActiveTextEditor()
    @setFieldsFromSelection()

    if uploadFn
      @imageInfoLayer.css({"display":"none"})
      @loadingLayer.css({"display":"block"})

      setTimeout =>
        uploadFn (err, data)=>
          @imageInfoLayer.css({"display":"block"})
          @loadingLayer.css({"display":"none"})

          if not err
            imgSrc = data.url
            @imageEditor.setText(imgSrc)
            @displayImagePreview(imgSrc)
            @titleEditor.focus()
          else
            @showMessage("upload error(#{err.code}): #{err.error}", "error")

      ,200

    else
      @imageInfoLayer.css({"display":"block"})
      @loadingLayer.css({"display":"none"})

    @panel.show()
    @imageEditor.focus()

  showMessage: (msg, type='info') ->
    @outputMessage.text(msg)
    @outputMessage.attr('class', 'text-'+type)

  displayImagePreview: (imgSrc) ->
    return if @imageOnPreview == imgSrc

    @showMessage("Opening Image Preview ...")
    @imagePreview.attr("src", imgSrc)
    @imagePreview.load =>
      @showMessage("Image is ready! now you can set title then press enter!", 'success')
    @imagePreview.error =>
      @showMessage("Error: Failed to Load Image.", 'error')
      @imagePreview.attr("src", "")

    @imageOnPreview = imgSrc # cache preview image src

  setFieldsFromSelection: ->
    @range = utils.getTextBufferRange(@editor, "link")
    selection = @editor.getTextInRange(@range)
