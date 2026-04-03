% Apply coherence filter
function d_out = sim_apply_pfilter(d_in, H, p)

d_out = cell(size(d_in));
for n = 1:length(H)
    d_out{n} = d_in{n} .* (H(n).P_matrix == p);
end

end