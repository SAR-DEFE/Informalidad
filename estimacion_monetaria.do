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
 }
 else if "`c(username)'" == "Owner" {
	 global path "C:\Users\Owner\OneDrive - SAR\Informalidad"
	 global out  "C:\Users\Owner\OneDrive - SAR\Notas técnicas y papers\Economía informal\out informalidad"
 }
 else if "`c(username)'" == "jcabrera" { 										// <- Usuario de Bayardo
	 global path ""
	 global out  ""
 }
 else if "`c(username)'" == "" {												// <- Usuario de Francisco
	 global path ""
	 global out  ""
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
 
 eststo drop *
 eststo eq1a: prais bm_m2 trib1 dum08 dum09, vce(robust) ssesearch 
 eststo eq1b: prais bm_m2 trib1 pib_pc dum08 dum09, vce(robust) ssesearch 
 eststo eq1c: prais bm_m2 trib1 pib_pc remu dum08 dum09, vce(robust) ssesearch 
 eststo eq1d: prais bm_m2 trib1 pib_pc remu tir dum08 dum09, vce(robust) ssesearch
 
 esttab eq1* using "$out\modelo1.tex", replace f booktabs se(2) b(3) star(* 0.10 ** 0.05 *** 0.01) scalars("N N" "r2 $R^2$" "rho $\rho$")
 
 eststo eq2a: prais bm_m3 trib1 dum08 dum09, vce(robust) ssesearch 
 eststo eq2b: prais bm_m3 trib1 pib_pc dum08 dum09, vce(robust) ssesearch 
 eststo eq2c: prais bm_m3 trib1 pib_pc remu dum08 dum09, vce(robust) ssesearch 
 eststo eq2d: prais bm_m3 trib1 pib_pc remu tir dum08 dum09, vce(robust) ssesearch 
 
 esttab eq2* using "$out\modelo2.tex", replace f booktabs se(2) b(3) star(* 0.10 ** 0.05 *** 0.01) scalars("N N" "r2 $R^2$" "rho $\rho$")
 
 
 
 
 
 
 
 