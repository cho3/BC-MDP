%drchrnd.m
%sample n  row vectors of dirichlet random variables with parameters a
%taken from Peter Perkins:
%http://www.mathworks.com/matlabcentral/newsreader/view_thread/65818

function r = drchrnd(a,n)
    p = length(a);
    r = gamrnd(repmat(a,n,1),1,n,p);
    r = r ./ repmat(sum(r,2),1,p);
end