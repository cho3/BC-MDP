%tileCode
%return the active index for each of the tiles
function phi = tileCode(x,bounds,num_feat,num_tiles,resolution)

    num_var = numel(x);
    %error check
    if num_var ~= numel(bounds) || num_var ~= numel(resolution) ||...
            numel(resolution) ~= numel(bounds)
        error('Incorrect number of variables for initialized tile coding')
    end

    phi = zeros(num_feat,1);
    num_feat_per_tile = prod(resolution);
    
    for i = 1:num_tiles
        m = zeros(1,num_var);
        for j = 1:num_var
            u = bounds{j}(i,2:end);
            l = bounds{j}(i,1:end-1);
            %there's only one
            m(j) = find(((x(j) > l) & (x(j) < u)) > 0,1,'first'); 
        end
        index = sum((m(1:end-1)-1).*resolution(1:end-1)) + m(end);
        phi((i-1)*num_feat_per_tile + index) = 1;
    end

end