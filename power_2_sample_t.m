function beta = power_2_sample_t(mu1, mu2, sd, n1, n2, alpha)

z = (mu1 - mu2)/(sd.*(sqrt(1./n1 + 1./n2)));

z_alpha = norminv(1 - alpha/2, 0, 1);

beta = 1 - (normpdf(z - z_alpha, 0, 1) + normpdf(-z - z_alpha, 0, 1));