qiniu = require "qiniu"
crypto = require "crypto"

module.exports = class imageUploader

  constructor: (uploadInfo) ->
    qiniu.conf.ACCESS_KEY = uploadInfo.ak
    qiniu.conf.SECRET_KEY = uploadInfo.sk
    @ak = uploadInfo.ak
    @sk = uploadInfo.sk
    @domain = uploadInfo.domain
    @bucket = uploadInfo.bucket;
    @token = @getToken()
    #console.log('tonken='+@token)

  getToken: () ->
    putPolicy = new qiniu.rs.PutPolicy(@bucket)
    return putPolicy.token()

  getKey: (imgbuffer) ->
    fsHash = crypto.createHash('md5')
    fsHash.update(imgbuffer)
    return fsHash.digest('hex')

  upload: (img, callback) ->
    imgbuffer = img.toPng()
    imgkey = @getKey(imgbuffer)

    qiniu.io.put @token, "#{imgkey}.png" , imgbuffer, null, (err, ret) =>
      if !err
        #console.log(ret.key, ret.hash)
        callback(null, {ret: ret, url:"#{@domain}/#{ret.key}"})
      else
        #console.log(err)
        callback(err)
