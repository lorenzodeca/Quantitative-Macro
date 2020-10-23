cd "C:\Users\lollo\Desktop"
import exc "tasso_occupazione.xlsx", firstrow

asgen pre_tot = totale if id_anno!=2020, w(id_anno) by(id_mese)

replace pre_tot = pre_tot[1] if id_tri==29
replace pre_tot = pre_tot[2] if id_tri==30
replace pre_tot= . if id_anno!=2020

line totale pre_tot id_tri

line elementari media diploma laurea id_tri, legend(size(medsmall))

