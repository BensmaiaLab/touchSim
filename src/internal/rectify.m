function vr = rectify(v)

vr = v;
vr(vr<0) = 0;
