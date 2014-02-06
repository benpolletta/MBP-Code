/*$Header: /data/nil-bluearc/raichlef/biyu/programs/RCS/Economic_data_analysis.c,v 1.1 2009/04/29 16:58:53 biyuh Exp biyuh $*/
/****************************************************************************************/
/* Copyright 2009, 2010	 B. J. He and A. Z. Snyder					*/
/* Washington University, Mallinckrodt Institute of Radiology.				*/
/* All Rights Reserved.									*/
/****************************************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <float.h>
#include <assert.h>
#include <unistd.h>
#include <calloc_subs.h>
#include <librms.h>

#define MAXL		256		/* filename character length */
#define MAXS		1024		/* input string length */

typedef struct {
	char		datroot[MAXL];
	char		datfile[MAXL];
	float		delta;
	int		nsample;
	int		nwindow;
} RUN_INFO;


/********************/
/* global variables */
/********************/
char		rcsid[] = "$Id: Economic_data_analysis.c,v 1.1 2009/04/29 16:58:53 biyuh Exp biyuh $";
char		program[MAXL];

void errm (char* program) {
	fprintf (stderr, "%s: memory allocation error\n", program);
	exit (-1);
}

void errr (char* program, char* filespc) {
	fprintf (stderr, "%s: %s read error\n", program, filespc);
	exit (-1);
}

void errw (char* program, char* filespc) {
	fprintf (stderr, "%s: %s write error\n", program, filespc);
	exit (-1);
}

void errf (char* program, char* filespc) {
	fprintf (stderr, "%s: %s format error\n", program, filespc);
	exit (-1);
}

void getroot (char *filespc, char *filroot) {
	char	*str;
	strcpy (filroot, filespc);
	while (str = strrchr (filroot, '.')) {
			if (!strcmp (str, ".dat"))	*str = '\0';
		else	break;
	}
}


int split (char *string, char *srgv[], int maxp) {
	int	i, m;
	char	*ptr;

	if (ptr = strchr (string, '#')) *ptr = '\0';
/**********************************/
/* convert '[', ']', ',' to space */
/**********************************/
	ptr = string; while (ptr = strpbrk (ptr, "[],")) *ptr = '\x20';
	i = m = 0;
	while (m < maxp) {
		while (!isgraph ((int) string[i]) && string[i]) i++;
		if (!string[i]) break;
		srgv[m++] = string + i;
		while (isgraph ((int) string[i])) i++;
		if (!string[i]) break;
		string[i++] = '\0';
	}
	return m;
}

double zeromean (float *f, int n) {
	int		i;
	double		u;

	for (u = i = 0; i < n; i++) u += f[i];
	u /= n;
	for (i = 0; i < n; i++) f[i] -= u;
	return u;
}

double unitvar (float *f, int npts) {
	int		i;
	double		v;

	for (v = i = 0; i < npts; i++) v += f[i]*f[i];
	v /= npts; v = sqrt (v);
	for (i = 0; i < npts; i++) f[i] /= v;
	return v;
}

void usage (char *program) {
	fprintf (stderr, "Usage:\t%s <data_list>\n", program);
	fprintf (stderr, "\toption\n");
	fprintf (stderr, "\t-2\tuse half-overlapping windows\n");
	fprintf (stderr, "\t-s<flt>\tspecify window (in days) for epoched FFT (default: 1000)\n");
	fprintf (stderr, "\t-z<flt>\tspecify length in day for zero padding (default :0)\n");
	fprintf (stderr, "\t-r\ttake out DC and trend for each window\n");
	fprintf (stderr, "\t-h\tuse Hanning window\n");
	fprintf (stderr, "\t-P\toutput power spectrum\n");
	fprintf (stderr, "\t-N\toutput amplitude_bin_by_phase file\n");
	fprintf (stderr, "\t-p[l|h]<flt>\tspecify low and high end half freq in cycle/day for phase extraction\n");
	fprintf (stderr, "\t-a[l|h]<flt>\tspecify low and high end half freq in cycle/day for amplitude extraction\n");
	fprintf (stderr, "\t-o<int>\tspecify butterworth filter order (default: 3)\n");
	fprintf (stderr, "\t-W\t write phase histogram of the lower frequency\n");
	fprintf (stderr, "\t-S\tshuffle and specify sequence file after datalist\n");
	exit (1);
}

int main (int argc, char *argv[]) {
	char		*ptr, command[MAXL], string[4*MAXL], *srgv[MAXL];
	int		c, i, j, k, l, m, n, TEMP, I;
	float		part_low, part_high;

/************/
/* file i/o */
/************/
	RUN_INFO	*runspc;
	FILE		*datfp;
	FILE		*lstfp;
	FILE		*outfp;
	FILE		*seqfp;
	char		lstfile[MAXL], outfile[MAXL], seqfile[MAXL];

/*****************/
/* EEG variables */
/*****************/
	int		irun, nrun = 0;
	float		delta, rate;			
	float		*data, *DATA;
	float		windows = 1000;
	float		pads = 0;
	int		windowp, padp=0, windowpp;
	int		nshuffle, ishuffle, mshuffle;
	int		**seq;
	float		*bartlett;
	float		*hanning;

/**************************/
/* EEG spectral variables */
/**************************/
	int		order_lo[2];
	int		order_hi[2];
	int		order = 3;
	float		flo[2] = {1., 0.};
	float		fhi[2] = {1., 0.};
	double		*r_lo, *r_hi, **factor_lo, **factor_hi;

/*******/
/* FFT */
/*******/
	double		*FFTA, *FFTB;
	double		**ffta, **fftb;
	double 		*phase, *amplitude, *amplitude_occur, *amplitude_norm, *amplitude_sum; 
	double		**amplitude_occur_shuffle, **amplitude_norm_shuffle, **amplitude_sum_shuffle; 
	double		*psd;
	float		hzpbin;
	int		one = 1, negone = -1, zero = 0;
	int		nbin;
	int		iwindow, sum_nwindow = 0;
	int		count_nwindow = 0;

/*********/
/* flags */
/*********/
	int		stagger = 0;
	int		status = 0;
	int		padflag = 0;
	int		detrend = 0;
	int		write_phase = 0;
	int		hann_flag = 0;
	int		psd_flag = 0;
	int		nested_flag = 0;
	int		shuffle = 0;

	fprintf (stdout, "#%s\n", rcsid);
	if (!(ptr = strrchr (argv[0], '/'))) ptr = argv[0]; else ptr++;
	strcpy (program, ptr);

/************************/
/* process command line */
/************************/
	for (k = 0, i = 1; i < argc; i++) {
		if (*argv[i] == '-') {
			strcpy (command, argv[i]); ptr = command;
			while (c = *ptr++) switch (c) {
				case '2': stagger++;			break;
				case 's': windows = atof (ptr);		*ptr = '\0'; break;
				case 'o': order = atoi (ptr);		*ptr = '\0'; break;
				case 'h': hann_flag++;			break;
				case 'z': padflag++; pads = atof (ptr);	*ptr = '\0'; break;
				case 'r': detrend++;			break;
				case 'p': switch (*ptr++) {
					case 'l': flo[0] = atof (ptr);	break;
					case 'h': fhi[0] = atof (ptr); 	break;
					default: usage (program);	break;
				}					*ptr = '\0'; break;
				case 'a': switch (*ptr++) {
					case 'l': flo[1] = atof (ptr);	break;
					case 'h': fhi[1] = atof (ptr); 	break;
					default: usage (program);	break;						
				}					*ptr = '\0'; break;
				case 'P': psd_flag++;			break;
				case 'N': nested_flag++;		break;
				case 'W': write_phase++;		break;
				case 'S': shuffle++;			break;
			}
		}
		else switch (k) {
			case 0: strcpy (lstfile, argv[i]);		k++; break;
			case 1: strcpy (seqfile, argv[i]);		k++; break;
		}
	}
	if (k < 1) usage (program);
	printf ("#%s", program); for (i = 1; i < argc; i++) printf (" %s", argv[i]); printf ("\n");
	printf ("lstfile: %s; seqfile: %s\n", lstfile, seqfile);
/*******************/
/* scan input list */
/*******************/
	if (!(lstfp = fopen (lstfile, "r"))) errr (program, lstfile);
	nrun = 0; while (fgets (string, MAXL, lstfp)) nrun++; rewind (lstfp);  /*count lines*/
	if (!(runspc = (RUN_INFO *) calloc (nrun, sizeof (RUN_INFO)))) errm (program);
	nrun = 0;
	while (fgets (string, MAXL, lstfp)) {
		if (!(m = split (string, srgv, MAXL))) continue;	/* skip blank lines */
		strcpy (runspc[nrun].datroot, srgv[0]);
		getroot (runspc[nrun].datroot, runspc[nrun].datroot);
		printf("datroot:%s\n",runspc[nrun].datroot);
		sprintf (runspc[nrun].datfile, "%s.dat",runspc[nrun].datroot);
		
		if (!(datfp = fopen (runspc[nrun].datfile, "r"))) errr (program, runspc[nrun].datfile);
		for (k = 0; k < 2; k++) {
			fgets (string, MAXS, datfp);
			n = split (string, srgv, MAXL);
			if (k==1) {
				runspc[nrun].delta = atof (srgv[0]); 
				runspc[nrun].nsample = atof (srgv[1]);	*ptr = '\0'; break;
			}
		}

		fprintf (stderr, "datfile: %s   delta=%.4f; nsample=%i\n", runspc[nrun].datfile, runspc[nrun].delta, runspc[nrun].nsample);
		status |= runspc[nrun].delta != runspc[0].delta;
		if (status) {printf("file inconsistent\n"); exit (-1);}
		fclose (datfp);
		nrun++;
	}
	fclose (lstfp);

	delta = runspc[0].delta;
	rate = 1/delta;
	windowp = windows * rate;
	windowpp = (windows + 2*pads) * rate;
	hzpbin = 1/(windows + 2*pads);
	nbin = windowpp/2+1;
	padp = pads * rate;

	for (i=0; i<nrun;i++) {
		runspc[i].nwindow = runspc[i].nsample/windowp;
		if (stagger) {runspc[i].nwindow = 2*runspc[i].nwindow - 1;}
		printf ("run=%d, nwindow = %d\n",i+1,runspc[i].nwindow);
	}

	printf("windowp:%d\twindowpp:%d\thzpbin:%.4fHz\tnbin:%d\n",windowp,windowpp,hzpbin,nbin);


/*******************/
/* allocate memory */
/*******************/
	if (!(data = (float *) calloc (windowp, sizeof (float)))) errm (program);
	if (!(DATA = (float *) calloc (windowp, sizeof (float)))) errm (program);

	if (!(FFTA = (double *) calloc (windowpp, sizeof (double)))) errm (program);
	if (!(FFTB = (double *) calloc (windowpp, sizeof (double)))) errm (program);
	
	ffta = calloc_double2 (2,windowpp);
	fftb = calloc_double2 (2,windowpp);

	if (!(amplitude = (double *) calloc(windowp, sizeof (double)))) errm (program);
	if (!(phase = (double *) calloc (windowp, sizeof (double)))) errm (program);
	if (!(amplitude_norm = (double *) calloc (20, sizeof (double)))) errm (program);
	if (!(amplitude_occur = (double *) calloc (20, sizeof (double)))) errm (program);
	if (!(amplitude_sum = (double *) calloc(20, sizeof (double)))) errm (program);

	if (!(r_lo = (double *) calloc (windowpp , sizeof (double)))) errm (program);
	if (!(r_hi = (double *) calloc (windowpp , sizeof (double)))) errm (program);
	factor_lo = calloc_double2 (2, windowpp);
	factor_hi = calloc_double2 (2, windowpp);
	if (!(psd = (double *) calloc (nbin , sizeof (double)))) errm (program);
	seq = calloc_int2 (MAXL, MAXL);

/***************************************/
/* scan shuffle sequence specification */
/***************************************/
if (shuffle) {
	printf("reading: %s\n", seqfile);
	if (!(seqfp = fopen (seqfile, "r"))) errr (program, seqfile);
	nshuffle = 0;
	while (fgets (string, MAXL, seqfp)) {
		m = split (string, srgv, MAXL);
		if (nshuffle == 0) {mshuffle = m;}
		if (m != mshuffle) {
			fprintf (stderr, "%s: %s format error\n", program, seqfile);
			exit (-1);
		}
		for (i = 0; i < m; i++) {
			seq[nshuffle][i] = atoi (srgv[i]);
			printf("%i ",seq[nshuffle][i]);
		}
		printf("\n");
		nshuffle++;
	}
	fclose (seqfp);
	amplitude_norm_shuffle 	= calloc_double2 (nshuffle,20);
	amplitude_occur_shuffle = calloc_double2 (nshuffle,20);
	amplitude_sum_shuffle 	= calloc_double2 (nshuffle,20);
}

/**************************/
/* set up Hanning weights */
/**************************/
	if (!(hanning = (float *) malloc (windowp * sizeof (float)))) errm (program);
	for (i = 0; i < windowp; i++) hanning[i] = (hann_flag) ? sqrt(2.)*0.5*(1.0 - cos(2.*M_PI*i/(windowp-1))) : 1.0;

/****************************************/
/* set up butterworth filtering weights */
/****************************************/
	order_lo[0] = order_lo[1] = order_hi[0] = order_hi[1] = order;
	if (flo[0] == 0) order_lo[0] = 0;
	for (j = 0; j <= 1; j++) {
		for (k = 0; k <= windowpp/2; k++) {
			if (order_lo[j] > 0) {
				r_lo[k] = pow((k * hzpbin/flo[j]),(2*order_lo[j]));
				factor_lo[j][k] = r_lo[k]/(1.0 + r_lo[k]);
			} else {
				factor_lo[j][k] = 1.0;
			}
			if (order_hi[j] > 0) {
				r_hi[k] = pow((k * hzpbin/fhi[j]),(2*order_hi[j]));
				factor_hi[j][k] = 1.0/(1.0 + r_hi[k]);
			} else {
				factor_hi[j][k] = 1.0;
			}
		}
		for (k = windowpp/2 + 1; k < windowpp; k++) {
			factor_lo[j][k] = factor_lo[j][windowpp - k];
			factor_hi[j][k] = factor_hi[j][windowpp - k];
		}
	}

/****************/
/* perform  FFT */ 
/****************/
for (irun = 0; irun < nrun; irun++) {
	if (!(datfp = fopen (runspc[irun].datfile, "r"))) errr (program, runspc[nrun].datfile);
	for (k = 0; k < 3; k++) fgets (string, MAXS, datfp);

	for (iwindow = 0; iwindow < runspc[irun].nwindow; iwindow++) {
		if (iwindow>0 && stagger) {
			for (k = 0; k < windowp/2; k++) data[k] = DATA[k+windowp/2];
			for (k=windowp/2; k < windowp; k++) {
				fgets (string, MAXS, datfp);
				split (string, srgv, MAXL);
				DATA[k] = data[k] = atof (srgv[1]);
			}
		} else {
			for (k = 0; k < windowp; k++) {
				fgets (string, MAXS, datfp);
				split (string, srgv, MAXL);
				DATA[k] = data[k] = atof (srgv[1]); 
			}
		}
			
		if (detrend) {
			for (i = 1; i < windowp - 1; i++) {
			data[i] -= data[0] + i*(data[windowp-1] - data[0])/(windowp-1);}
			data[0] = data[windowp - 1] = 0;
		}

		for (i = 0; i < padp; i++) FFTA[i] = FFTB[i] = 0;

		for (i = padp; i < windowp + padp; i++) {
			FFTA[i] = data[i-padp];
			FFTB[i] = 0;
		}

		for (i = windowp + padp; i < windowpp; i++) FFTA[i] = FFTB[i] = 0;

		dfft_   (FFTA, FFTB, &one, &windowpp, &one, &negone);

		if (psd_flag) {
			psd[0] += FFTA[0]*FFTA[0];
			for (i=1; i < windowpp/2; i++) {
				psd[i] += 2.*(FFTA[i] * FFTA[i] + FFTB[i] * FFTB[i]);
			}
			psd[windowpp/2] += FFTA[windowpp/2]*FFTA[windowpp/2];
		}


		if (nested_flag) {
			for (j = 0; j<=1; j++) {
				ffta[j][0] = FFTA[0] * sqrt(factor_lo[j][0] * factor_hi[j][0]);
				fftb[j][0] = FFTB[0] * sqrt(factor_lo[j][0] * factor_hi[j][0]);
				for (i = 1; i <= windowpp/2; i++) {
					ffta[j][i] = 2 * FFTA[i] * sqrt(factor_lo[j][i] * factor_hi[j][i]);
					fftb[j][i] = 2 * FFTB[i] * sqrt(factor_lo[j][i] * factor_hi[j][i]);
				}
				for (i = windowpp/2 + 1; i < windowpp; i++) {
					ffta[j][i] = fftb[j][i] = 0;
				}
				dfft_   (ffta[j], fftb[j], &one, &windowpp, &one, &one);
			}
			for (i = padp; i < windowp + padp; i++) {
				amplitude[i-padp] = sqrt(ffta[1][i] * ffta[1][i] + fftb[1][i] * fftb[1][i]);
				phase[i-padp] = atan2 (fftb[0][i], ffta[0][i]);
			}
			if (shuffle) {
				for (ishuffle = 0; ishuffle < nshuffle; ishuffle++) {
					for (k = 0; k < mshuffle; k++) {
						for (i = 0; i < windowp/mshuffle; i++) {
							for (j = 0; j < 20; j++) {
								part_low = (j-10.)/10.*M_PI;
								part_high = part_low + 0.1*M_PI;
								m = seq[ishuffle][k]*windowp/mshuffle + i;
								n = k * windowp / mshuffle + i;
								if (part_low <= phase[m] && phase[m] < part_high) {
									amplitude_sum_shuffle[ishuffle][j] += amplitude[n];
									amplitude_occur_shuffle[ishuffle][j] += 1.0;
								}
							}
						}
					}
				}
			} else {
				for (i = padp; i < windowp + padp; i++) {
					for (j = 0; j < 20; j++) {
						part_low = (j-10.)/10.*M_PI;
						part_high = part_low + 0.1*M_PI;
						if (part_low <= phase[i-padp] && phase[i-padp] < part_high) {
							amplitude_sum[j] += amplitude[i-padp];
							amplitude_occur[j] += 1.0;
						}
					}
				}
			}
		}
		count_nwindow++;
	}
	sum_nwindow += runspc[irun].nwindow;
	if (fclose (datfp)) errr (program, runspc[irun].datfile);
}
printf("check consistency: sum_nwindow = %d windowpp=%d count_nwindow=%d\n", sum_nwindow, windowpp, count_nwindow);

if(nested_flag) {
	if (shuffle) {
		for (ishuffle = 0; ishuffle < nshuffle; ishuffle++) {
			for (k = 0; k < 20; k++){
				amplitude_norm_shuffle[ishuffle][k] = amplitude_sum_shuffle[ishuffle][k] / amplitude_occur_shuffle[ishuffle][k];
			}
		}
	} else {
		for (k = 0; k < 20; k++){
			amplitude_norm[k] = amplitude_sum[k] / amplitude_occur[k];
			if (write_phase) amplitude_occur[k] /= sum_nwindow * windowp;
		}
	}
}
if (psd_flag)	{for (i = 0; i < nbin; i++) psd[i] /= (1.*sum_nwindow * windowpp * windowpp);}

/******************************/
/* write amp bin by phase file*/
/******************************/
if (nested_flag) {
	if (shuffle) {
		for (ishuffle = 0; ishuffle < nshuffle; ishuffle++) {
			while (ptr = strrchr (lstfile, '.')) *ptr = '\0';
			sprintf (outfile, "%s_amplitude%.2f-%.2fHz_bin_by_phase%.3f-%.3fHz_shuffle%d.dat", lstfile, flo[1],fhi[1],flo[0],fhi[0],ishuffle+1);
			if (!(outfp = fopen (outfile, "w"))) errw (program, outfile);
			fprintf (stderr, "Writing: %s\n", outfile);
			fprintf (outfp, "#%s", program);
			for (k = 1; k < argc; k++) fprintf (outfp, " %s", argv[k]); fprintf (outfp, "\n");
			fprintf (outfp, "#amp_mean -1~-0.9pi -0.9~-0.8pi -0.8~-0.7pi -0.7~-0.6pi -0.6~-0.5pi -0.5~-0.4pi -0.4~-0.3pi -0.3~-0.2pi -0.2~-0.1PI -0.1~0PI 0~0.1PI 0.1~0.2pi 0.2~0.3pi 0.3~0.4pi 0.4~0.5pi 0.5~0.6pi 0.6~0.7pi 0.7~0.8pi 0.8~0.9pi 0.9~1pi\n");
			for (i=0; i<20; i++) fprintf (outfp, " %.10f\t", amplitude_norm_shuffle[ishuffle][i]);
			fprintf (outfp, "\n");
			if (fclose (outfp)) errw (program, outfile);
		}
	} else {
		sprintf (outfile, "%s_amplitude%.2f-%.2fHz_bin_by_phase%.3f-%.3fHz.dat", lstfile, flo[1],fhi[1],flo[0],fhi[0]);
		if (!(outfp = fopen (outfile, "w"))) errw (program, outfile);
		fprintf (stderr, "Writing: %s\n", outfile);
		fprintf (outfp, "#%s", program);
		for (k = 1; k < argc; k++) fprintf (outfp, " %s", argv[k]); fprintf (outfp, "\n");
		fprintf (outfp, "#amp_mean -1~-0.9pi -0.9~-0.8pi -0.8~-0.7pi -0.7~-0.6pi -0.6~-0.5pi -0.5~-0.4pi -0.4~-0.3pi -0.3~-0.2pi -0.2~-0.1PI -0.1~0PI 0~0.1PI 0.1~0.2pi 0.2~0.3pi 0.3~0.4pi 0.4~0.5pi 0.5~0.6pi 0.6~0.7pi 0.7~0.8pi 0.8~0.9pi 0.9~1pi\n");
		for (i=0; i<20; i++) fprintf (outfp, " %10.4f", amplitude_norm[i]);
		fprintf (outfp, "\n");
		if (fclose (outfp)) errw (program, outfile);
	}
}

if (write_phase) {
	sprintf (outfile, "%s_%.3f-%.3fHz_phase_histogram.dat", lstfile, flo[0],fhi[0]);
	if (!(outfp = fopen (outfile, "w"))) errw (program, outfile);
	fprintf (stderr, "Writing: %s\n", outfile);
	fprintf (outfp, "#%s", program);
	for (k = 1; k < argc; k++) fprintf (outfp, " %s", argv[k]); fprintf (outfp, "\n");
	fprintf (outfp, "#frequency -1~-0.9pi -0.9~-0.8pi -0.8~-0.7pi -0.7~-0.6pi -0.6~-0.5pi -0.5~-0.4pi -0.4~-0.3pi -0.3~-0.2pi -0.2~-0.1PI -0.1~0PI 0~0.1PI 0.1~0.2pi 0.2~0.3pi 0.3~0.4pi 0.4~0.5pi 0.5~0.6pi 0.6~0.7pi 0.7~0.8pi 0.8~0.9pi 0.9~1pi\n");
	for (i=0; i<20; i++) fprintf (outfp, " %10.4f", amplitude_occur[i]);
	fprintf (outfp, "\n");
	if (fclose (outfp)) errw (program, outfile);
}

/********************************/
/* write psd of simulated signal*/
/********************************/
if (psd_flag) {
	sprintf (outfile, "%s.psd", lstfile);
	if (!(outfp = fopen (outfile, "w"))) errw (program, outfile);
	fprintf (stderr, "Writing: %s\n", outfile);
	fprintf (outfp, "#%s", program);
	for (k = 1; k < argc; k++) fprintf (outfp, " %s", argv[k]); fprintf (outfp, "\n");
	for (i=0; i<nbin; i++) fprintf (outfp, " %.4f\t\t%.6f\n",i*hzpbin,psd[i]);
	if (fclose (outfp)) errw (program, outfile);
}

FREE:
/***************/
/* free memory */
/***************/
	free_double2 (ffta); free_double2 (fftb); free (FFTA); free (FFTB);
	free (phase); free (amplitude); 
	free (amplitude_norm); free (amplitude_occur); free (amplitude_sum); 
	free (data); free (DATA); free (bartlett); free (hanning);
	free (r_lo); free (r_hi); 
	free_double2 (factor_lo); free_double2 (factor_hi); free (psd);
	if (shuffle) {free_double2 (amplitude_norm_shuffle); free_double2 (amplitude_sum_shuffle); free_double2 (amplitude_occur_shuffle);}
}

