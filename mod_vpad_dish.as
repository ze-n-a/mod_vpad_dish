;----------------------------------------------------------------
; �o�[�`�����p�b�h���W���[�� / onitama 2023
;  �g�p�Ɋւ��鐧���͂���܂���B�����R�ɂ��g�����������B
; mtinfo+thumb area+wpad(hsp3dish only) / ze-na 2025
;----------------------------------------------------------------

#include "hsp3dish.as"
#module "_vpad_dish"

#deffunc hspvpad_init int _p1, int _p2, int _p3, int _p4

	;	�o�[�`�����p�b�h�̏�����
	;	hspvpad_init p1,p2
	;	p1 : �p�b�h�摜���i�[����o�b�t�@ID
	;	p2 : �p�b�h�z�u(1=��PAD/2=��PAD/4=�ړ��̂�)
	;					8=�_�u��PAD/64=���͕\��
	;	p3 : X�����I�t�Z�b�g
	;	p4 : Y�����I�t�Z�b�g
	;
	vpbuf=_p1
	if vpbuf<=0 : vpbuf=ginfo(25)
	celload "vpad.png",vpbuf
	celdiv vpbuf,64,64
	vppos=_p2
	sx=ginfo_sx:sy=ginfo_sy
	vpadx=32:if vppos&1 : vpadx=sx-223
	i=22:if vppos&2 : i=4
	vpady=sy*i/30
	vpadx += _p3 : vpady += _p4
	;
	vpkey=0
	vpmax=0
	dim vp_key,16
	dim vp_id,16
	dim vp_x,16
	dim vp_y,16
	;
	if (vppos&8)=0 {
		hspvpad_addkey vpadx,vpady,1,7
		hspvpad_addkey vpadx+128,vpady,4,5
		hspvpad_addkey vpadx+64,vpady-64,2,4
		hspvpad_addkey vpadx+64,vpady+64,8,6
	}else{
		hspvpad_addkey vpadx,vpady,16384,7
		hspvpad_addkey vpadx+128,vpady,65536,5
		hspvpad_addkey vpadx+64,vpady-64,32768,4
		hspvpad_addkey vpadx+64,vpady+64,131072,6
	}
	;
	vpadx=sx-223:if vppos&1 : vpadx=32
	;
	if (vppos&4)=0 {
	if (vppos&8)=0 {
		hspvpad_addkey vpadx,vpady,16,3
		hspvpad_addkey vpadx+128,vpady,2048,0
		hspvpad_addkey vpadx+64,vpady-64,4096,2
		hspvpad_addkey vpadx+64,vpady+64,8192,1
	}else{
		hspvpad_addkey vpadx,vpady,1,7
		hspvpad_addkey vpadx+128,vpady,4,5
		hspvpad_addkey vpadx+64,vpady-64,2,4
		hspvpad_addkey vpadx+64,vpady+64,8,6
	}
	}
	;
	return


#deffunc hspvpad_addkey int _p1, int _p2, int _p3, int _p4

	;	�{�^���̔z�u(�����p)
	vp_x(vpmax)=_p1
	vp_y(vpmax)=_p2
	vp_key(vpmax)=_p3
	vp_id(vpmax)=_p4
	vpmax++
	return	


#deffunc hspvpad_set int _p1, int _p2, int _p3

	;	�o�[�`�����p�b�h�̃{�^���ʒu����
	;	hspvpad_set p1,p2,p3
	;	p1 : �{�^��ID(0=��/1=��/2=��/3=�E/4=�`�F�b�N/5=�Z/6=��/7=�~)
	;	p2 : X�ʒu(��΍��W) (�}�C�i�X�l�̏ꍇ�͕\���Ȃ�)
	;	p3 : Y�ʒu(��΍��W)
	;
	vp_x(_p1)=_p2
	vp_y(_p1)=_p3
	return


#deffunc hspvpad_stick int _p1, int _p2

	;	�o�[�`�����p�b�h�̃L�[�u������
	;	hspvpad_stick p1,p2
	;	p1 : �{�^��ID(0=��/1=��/2=��/3=�E/4=�`�F�b�N/5=�Z/6=��/7=�~)
	;	p2 : �L�[�l(stick���߂̃L�[���l)
	;
	vp_key(_p1)=_p2
	return


#deffunc hspvpad_key var _p1, int _p2

	;	�o�[�`�����p�b�h�̃L�[����
	;	hspvpad_key var
	;	var = stick�Œl���擾�����ϐ���
	;
	mtlist touchid:num=stat
	repeat num
		id=touchid(cnt):mtinfo touch,id
		t=touch(0):x=touch(1):y=touch(2)
		if t{
		    repeat vpmax
			x1=vp_x(cnt)
			if x1>=0 {
				x1+=32:y1=vp_y(cnt)+32
				if powf(x1-x,2)+powf(y1-y,2)<=powf(64,2) {
					_p1|=vp_key(cnt)
				}
			}
		    loop
		}
	loop
	vpkey=_p1
	return

#deffunc hspvpad_put int _p1, int _p2

	cx=ginfo_cx:cy=ginfo_cy
	rgb=(ginfo_r*65536)+(ginfo_g*256)+ginfo_b
	;	�o�[�`�����p�b�h�̕\������
	;	hspvpad_put p1
	;	p1 : ����ON���s��key�l
	;
	i=vpkey|_p1
	gmode 3,,,128
	repeat vpmax
		x=vp_x(cnt)
		if x>=0 {
			pos x,vp_y(cnt)
			j=vp_id(cnt):if i&vp_key(cnt) : j+=8
			celput vpbuf,j
			if (j>=8)&((vppos&64)!0){
				rgbcolor $ff
				circle x,vp_y(cnt),x+64,vp_y(cnt)+64,0
			}
		}
	loop
	if vppos&64{
	mtlist touchid:num=stat
	repeat num
		id=touchid(cnt):mtinfo touch,id
		t=touch(0):x=touch(1):y=touch(2)
		if t{
			rgbcolor $ffff:circle x-32,y-32,x+32,y+32,0
			rgbcolor $ffff00:circle x-64,y-64,x+64,y+64,0
			pos x-64,y-64:mes strf("#%02d",id+1)
		}
	loop
	}
	rgbcolor rgb:pos cx,cy
	return

#global

