clear;
path='walk_qcif.avi';
vr=VideoReader(path);
frames=read(vr);
[out_buff_y, out_buff_cb, out_buff_cr, mvlbuff, mvcbuff]=encoder(path);
decoder(out_buff_y, out_buff_cb, out_buff_cr, mvlbuff, mvcbuff, frames);