function deltaM = auxil_asl_model_buxton(cbf, tt, ld, pld, T1t, T1b, lambda, eff)

    deltaM = 2 .* cbf * eff * T1t * (1/lambda) .* exp(-pld/T1b) .* ...
        (exp(-max(pld - tt, 0)./T1t) - exp(-max(ld+pld-tt, 0)./T1t));

end