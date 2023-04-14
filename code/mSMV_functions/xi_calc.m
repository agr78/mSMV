function xi = xi_calc(CF,delta_TE,tmin)

    xi = tmin./(CF.*delta_TE.*2*pi);
end