function getTiles = initTileCode(n,resolution,numTiles)
    %assume a statespace of [0,1]^n
    %resolution is how many tiles to break the space into (approximately)
    %this induces numTiles*PI_i resolution(i) features
    %also assumes a rectangular grid
    %this is done explicitly, with no hasing because im awful
    %================================
    %maybe leave everything between ='s in an 'init tile code' function
    %that returns a tile code function, save computation (at expense of
    %some memory)
%     n = numel(x);
    if numel(resolution) ~= n
        if numel(resolution) ~= 1
            error(['Error: improper number of resolution variables, ', ...
                'use 1 or |x|']);
%             return;
        end
        resolution = resolution*ones(n,1);
    end
    
    %the base tile fits squarely on top of the state space, with a
    %overbleed of 1/2 grid size in each dimension (both in the <0 and >1
    %parts)
    bounds0 = cell(n,1);
    h = zeros(1,n);
    for i = 1:n
        bounds0{i} = zeros(1,resolution(i)+1);
        h(i) = 1/(resolution(i)-1);
        bounds0{i}(1,:) = (0:h(i):(1+h(i))) - (h(i)/2);
    end
    
    offsets = rand(numTiles,n)*2-1;
    offsets = offsets.*repmat(h/2,numTiles,1); %something involving h to scale
    
    bounds = cell(n,1);
    
    for j = 1:n %            vert stack              horizontal stack
        bounds{j} = repmat(bounds0{j}(1,:),numTiles,1) +...
            repmat(offsets(:,j),1,resolution(j)+1);
    end
    
    
    %============================
    %end init domain
    num_features = prod(resolution)*numTiles;
    
    getTiles = @(x) tileCode(x,bounds,num_features,numTiles,resolution);

end