%bcmdp_featureFunctionTiles.m
%wrapper to map my domain to the tile code [0,1]^n domain

function phi = bcmdp_featureFunctionTiles(s,k,getTiles,num_feat,bc,mdp)
    phi = zeros(num_feat*mdp.m,1);
    %don't know how to handle explicit...
    %well you can, it'll just be pretty nasty
    if strcmpi(mdp.feature_type,'tile')
        for j = 1:mdp.m
            if mdp.m ~= 1 || mdp.MAS <= 1
                k = j;
            end
            for i = 1:bc.n
                if i ~= j
%                 feat = [(s(i)-s(k))/2 + 0.5, s(k)];
                feat = [s(i) s(k)];
                phi(1 + (j-1)*num_feat:j*num_feat) = ...
                    phi(1 + (j-1)*num_feat:j*num_feat) + getTiles(feat);
                end
            end
        end
        
        if strcmpi(mdp.feature_scaling,'binary')
            phi = bsxfun(@min,phi,1);
        elseif strcmpi(mdp.feature_scaling,'sqrt')
            phi = sqrt(phi);
        end

    else
        error('Cant handle this feature type');
    end

end