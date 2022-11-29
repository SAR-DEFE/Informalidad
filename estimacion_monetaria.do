/*
Título: estimación_monetaria.do
Detalle: do file empleado para estimar la economía informal de Honduras 2001-2021
		 usando el método de demanda del circulante.
*/

clear all

/*

Definir ubicaciones de la computadora:
global path: establece la dirección dónde se encuentran los datos
global out: establece la dirección dónde se guardarán los resultados

*/
 
 if "`c(username)'" == "jbermudez" {
	 global path "C:\Users\jbermudez\OneDrive - SAR\Informalidad"
	 global out  "C:\Users\jbermudez\OneDrive - SAR\Notas técnicas y papers\Economía informal\out informalidad"
	 global graphop "legend(region(lcolor(none))) graphr(color(white))"
 }
 else if "`c(username)'" == "Owner" {
	 global path "C:\Users\Owner\OneDrive - SAR\Informalidad"
	 global out  "C:\Users\Owner\OneDrive - SAR\Notas técnicas y papers\Economía informal\out informalidad"
	 global graphop "legend(region(lcolor(none))) graphr(color(white))"
 }
 else if "`c(username)'" == "jcabrera" { 										// <- Usuario de Bayardo
	 global path ""
	 global out  ""
	 global graphop "legend(region(lcolor(none))) graphr(color(white))"
 }
 else if "`c(username)'" == "" {												// <- Usuario de Francisco
	 global path ""
	 global out  ""
	 global graphop "legend(region(lcolor(none))) graphr(color(white))"
 }
 
 
 * Importar base de datos crudos y preparar variables antes de la estimación
 
 import excel using "$path\BDD_informalidad.xlsx", firstrow clear sheet("2001-2021")
 tsset year, yearly
 
 gen pib_pc = log(pib_percap)
 gen bm_m3  = log(billetes_monedas / m3)
 gen bm_m2  = log(billetes_monedas / m2)
 gen trib   = log(ingresos_tributarios / pib_nominal)
 gen trib1  = log(ingresos_tributarios)
 gen remu   = log(remuneraciones / pib_nominal)
 gen tir    = log(1 + (tasa_real / 100))
 
 gen dum08 = cond(year == 2008, 1, 0)
 gen dum09 = cond(year == 2009, 1, 0)
 gen dum20 = cond(year == 2020, 1, 0)
 
 
 * Pruebas de raíz unitaria
 
    varsoc trib1, exog(year)                
	dfuller trib1, lags(1) trend reg
	dfuller trib1, lags(1) reg
	dfuller trib1, lags(1) noconstant reg


 * Regresiones 
 
 eststo drop *
 eststo eq1a: prais bm_m2 trib1 dum09 dum20, vce(robust) ssesearch 
 eststo eq1b: prais bm_m2 trib1 pib_pc dum09 dum20, vce(robust) ssesearch 
 eststo eq1c: prais bm_m2 trib1 pib_pc remu dum09 dum20, vce(robust) ssesearch 
 eststo eq1d: prais bm_m2 trib1 pib_pc remu tir dum09 dum20, vce(robust) ssesearch
 
 esttab eq1* using "$out\modelo1.tex", replace f booktabs nomtitles se(2) b(3) star(* 0.10 ** 0.05 *** 0.01) scalars("N N" "r2 R$^2$" "rho $\rho$") ///
             coeflabels(trib1 "Log(Recaudación)" pib_pc "Log(PIB per capita)" remu "Log(Remuneraciones/PIB)" tir "Log($1$ + Tasa de interés)"  ///
			 _cons "Constante" dum09 "Dummy 2009" dum20 "Dummy 2020") order(trib1 pib_pc remu tir dum09 dum20 _cons)
 
 eststo eq2a: prais bm_m3 trib1 dum09 dum20, vce(robust) ssesearch 
 eststo eq2b: prais bm_m3 trib1 pib_pc dum09 dum20, vce(robust) ssesearch 
 eststo eq2c: prais bm_m3 trib1 pib_pc remu dum09 dum20, vce(robust) ssesearch 
 eststo eq2d: prais bm_m3 trib1 pib_pc remu tir dum09 dum20, vce(robust) ssesearch
 predict bm_m3_modelo2
 
 gen dif_ecm1 = (bm_m3 - bm_m3_modelo2)^2
 sum dif_ecm1, d
 loc ecm1: di %4.3f sqrt((1 / r(N)) * r(sum))
 tsline bm_m3 bm_m3_modelo2, $graphop legend(order(1 "Observada" 2 "Estimada")) xtitle("Año") xscale(titlegap(3)) text(-2.07 2018 "RECM = `ecm1'")
 graph export "$out\estimado_modelo2.pdf", replace
 
 esttab eq2* using "$out\modelo2.tex", replace f booktabs nomtitles se(2) b(3) star(* 0.10 ** 0.05 *** 0.01) scalars("N N" "r2 R$^2$" "rho $\rho$") ///
             coeflabels(trib1 "Log(Recaudación)" pib_pc "Log(PIB per capita)" remu "Log(Remuneraciones/PIB)" tir "Log($1$ + Tasa de interés)"  ///
			 _cons "Constante" dum09 "Dummy 2009" dum20 "Dummy 2020") order(trib1 pib_pc remu tir dum09 dum20 _cons)
			 
 eststo eq3a: prais bm_m3 trib1, vce(robust) ssesearch 
 eststo eq3b: prais bm_m3 trib1 pib_pc, vce(robust) ssesearch 
 eststo eq3c: prais bm_m3 trib1 pib_pc remu, vce(robust) ssesearch 
 eststo eq3d: prais bm_m3 trib1 pib_pc remu tir, vce(robust) ssesearch 
 predict bm_m3_modelo3 
 
 gen dif_ecm2 = (bm_m3 - bm_m3_modelo3)^2
 sum dif_ecm2, d
 loc ecm2: di %4.3f sqrt((1 / r(N)) * r(sum))
 tsline bm_m3 bm_m3_modelo3, $graphop legend(order(1 "Observada" 2 "Estimada")) xtitle("Año") xscale(titlegap(3)) text(-2.07 2018 "RECM = `ecm2'")
 graph export "$out\estimado_modelo3.pdf", replace
 
 esttab eq3* using "$out\modelo3.tex", replace f booktabs nomtitles se(2) b(3) star(* 0.10 ** 0.05 *** 0.01) scalars("N N" "r2 R$^2$" "rho $\rho$") ///
             coeflabels(trib1 "Log(Recaudación)" pib_pc "Log(PIB per capita)" remu "Log(Remuneraciones/PIB)" tir "Log($1$ + Tasa de interés)"  ///
			 _cons "Constante") order(trib1 pib_pc remu tir _cons)	
			 
			 
			 
 
 
 
 
 
 
 
 