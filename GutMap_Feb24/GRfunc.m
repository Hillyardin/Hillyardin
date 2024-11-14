%#################################
% GutMap 2014-2024
%#################################

function[sp,xtp,ztp] = GRfunc(edgeimg,N,S)

[x,y] = find(edgeimg);
nn = histcounts(y,0.5:1:(N+.5));
aa = 1:1:N;
vv = aa(nn==1 | nn==0);
[cc1,ia] = intersect(y,vv);
dd1 = x(ia);

if isempty(cc1) | isempty(dd1)
    sp = [];
    xtp = 0;
    ztp = 0;
    
else
    try
        cc2 = [1; cc1; N];
        dd2 = [dd1(1); dd1; dd1(end)];

        [cc3,ig] = unique(cc2);
        dd3 = dd2(ig);

        ydiff1 = dd3(2:end) - dd3(1:end-1);
        ydiff2 = dd3(3:end) - dd3(1:end-2);

        g1inds = find(abs(ydiff1) < 6);
        g2inds = find(abs(ydiff2) < 6);

        goodinds = [1; g2inds+2];

        dd = dd3(goodinds);
        cc = cc3(goodinds);

        sp = spaps(cc,dd,S);

        xtp = 1:1:N;
        ztp = fnval(sp,xtp);
    catch me
        sp = [];
        xtp = 0;
        ztp = 0;
    end;
end;

return;
