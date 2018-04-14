# Markdown Assistant
An assistant for markdown writers.

For now there is only one feature:
- Upload images or image files from the clipboard automatically.

## Upload images from the clipboard

![upload image](http://7xkrm0.com1.z0.glb.clouddn.com/72b078601683bd35ad459172977a620f.png)


### Prepare an uploader
You need prepare an `uploader` to upload image.

How?

1. Find an uploader plugin and install it!
> you can find some of them [here](https://github.com/knightli/markdown-assistant/wiki/plugins#uploader)  
> or search in atom with keywords `uploader` + `assistant`

2. set uploader package name as `uploader` in settings.  
![settings outter](http://7xkrm0.com1.z0.glb.clouddn.com/46304a9b336ebb2cdde5c7ccc6f70d29.png)

3. config your uploader package in settings for upload ( [example](https://github.com/knightli/qiniu-uploader) )

### Usage
1. Take a screenshot or copy any image to the clipboard.
2. Paste it into Atom by `cmd` + `v` (or `ctrl` + `v`).
3. It's uploading now. Wait for secs.
4. See preview for the uploaded image and maybe add a title for it.
5. Press `enter` to insert the image.

### Uploaders

Now we have the following uploaders

*   [qiniu-uploader](https://github.com/knightli/qiniu-uploader) for qiniu cloud
*   [qcloud-uploader](https://github.com/tychenjiajun/qcloud-uploader) for tencent qcloud
*   [oss-uploader](https://github.com/airclear/oss-uploader) for aliyun oss
