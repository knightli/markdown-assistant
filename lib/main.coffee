insertImageViewModule = require "./insert-image-view"

module.exports =
  config:
    suffixes:
      type: 'array'
      default: ['markdown', 'md', 'mdown', 'mkd', 'mkdow']
      items:
        type: 'string'
    qiniuAK:
      title: "qiniuAK"
      type: 'string'
      description: "在七牛后台 “账号设置 - 密钥” 下查看 AK 和 SK 的值"
      default: ""
    qiniuSK:
      title: "qiniuSK"
      type: 'string'
      description: "在七牛后台 “账号设置 - 密钥” 下查看 AK 和 SK 的值"
      default: ""
    qiniuBucket:
      title: "qiniuBucket"
      type: 'string'
      description: "在七牛后台 “选择一个空间” 下找一个空间名称"
      default: ""
    qiniuDomain:
      title: "qiniuDomain"
      type: 'string'
      description: "在七牛后台指定空间下 “空间设置 - 域名设置” 下查看空间绑定的域名"
      default: ""

  activate: (state) ->
    #console.log('markdown assistant activate')
    @attachEvent()

  attachEvent: ->
    workspaceElement = atom.views.getView(atom.workspace)
    workspaceElement.addEventListener 'keydown', (e) =>
      if (e.metaKey && e.keyCode == 86)
        clipboard = require('clipboard')
        img = clipboard.readImage()
        return if img.isEmpty()

        # insert loading text
        editor = atom.workspace.getActiveTextEditor()
        ak = atom.config.get('markdown-assistant.qiniuAK')
        sk = atom.config.get('markdown-assistant.qiniuSK')
        bucket = atom.config.get('markdown-assistant.qiniuBucket')
        domain = atom.config.get('markdown-assistant.qiniuDomain')
        if (ak && sk && bucket)
          uploadInfo = {
            img: img,
            uploader: {
              ak: ak,
              sk: sk,
              bucket: bucket,
              domain: domain
            }
          }
          insertImageViewInstance = new insertImageViewModule()
          insertImageViewInstance.display(uploadInfo)
        else
          #todo show message guide user go setting
