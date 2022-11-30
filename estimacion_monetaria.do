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
 
 
 
 *******************************************************************************
 * Importar base de datos crudos y preparar variables antes de la estimación
 *******************************************************************************
 
 import excel using "$path\BDD_informalidad.xlsx", firstrow clear sheet("2001-2021")
 tsset year, yearly
 
 gen trend  = _n
 gen pib_pc = log(pib_percap)
 gen trib   = log(ingresos_tributarios / pib_nominal)
 gen remu   = log(remuneraciones)
 gen tir    = log(1 + (tasa_real / 100))
 gen money  = log(billetes_monedas)
 
 gen dum09 = cond(year == 2009, 1, 0)
 gen dum20 = cond(year == 2020, 1, 0)
 gen dum21 = cond(year == 2021, 1, 0)
 
 
 *******************************************************************************
 * Pruebas de raíz unitaria
 *******************************************************************************
 
 * Ingresos tributarios I(0)
 varsoc trib, exog(year)                
 dfuller trib, lags(1) trend reg
 dfuller trib, lags(1) reg
 dfuller trib, lags(1) noconstant reg
	
 * Pib per cápita I(0)
 varsoc pib_pc, exog(year)                
 dfuller pib_pc, lags(1) trend reg
 dfuller pib_pc, lags(1) reg
 dfuller pib_pc, lags(1) noconstant reg
	
 * Remuneraciones I(1)
 varsoc remu, exog(year)                
 dfuller remu, lags(2) trend reg
 dfuller remu, lags(2) reg
 dfuller remu, lags(2) noconstant reg
	
 * Tasa de interés real I(1)
 varsoc tir, exog(year)                
 dfuller tir, lags(0) trend reg
 dfuller tir, lags(0) reg
 dfuller tir, lags(0) noconstant reg
	

	
 *******************************************************************************	
 * Regresiones para mostrar en el documento
 *******************************************************************************
 
 eststo drop *
 eststo eq_a: qui prais money trib trend, vce(robust) ssesearch
 eststo eq_b: qui prais money trib trend dum09 dum20 dum21, vce(robust) ssesearch 
 
 eststo eq_c: qui prais money trib pib_pc trend, vce(robust) ssesearch
 eststo eq_d: qui prais money trib pib_pc trend dum09 dum20 dum21, vce(robust) ssesearch
 
 eststo eq_e: qui prais money trib pib_pc remu trend, vce(robust) ssesearch 
 eststo eq_f: qui prais money trib pib_pc remu trend dum09 dum20 dum21, vce(robust) ssesearch 
 
 eststo eq_g: qui prais money trib pib_pc remu d.tir trend, vce(robust) ssesearch 
 eststo eq_h: qui prais money trib pib_pc remu d.tir trend dum09 dum20 dum21, vce(robust) ssesearch 
 predict money_modelo 	
			 
 gen dif_ecm = (money - money_modelo)^2
 sum dif_ecm, d
 loc ecm: di %4.3f sqrt((1 / r(N)) * r(sum))
 tsline money money_modelo, $graphop legend(order(1 "Observada" 2 "Estimada")) xtitle("Año") ytitle("Logaritmo: Billetes y Monedas") ///
        lw(medthick medthick) lc(red blue) lp(solid dash) text(9.5 2018 "RECM = `ecm'") xscale(titlegap(3)) yscale(titlegap(3))
 graph export "$out\estimado_modelo.pdf", replace
 graph close _all	
 
 esttab eq_* using "$out\modelo.tex", replace f booktabs nomtitles se(2) b(3) star(* 0.10 ** 0.05 *** 0.01) scalars("N N" "r2 R$^2$" "rho $\rho$" "rmse RECM") ///
             coeflabels(trib "Log(Presión tributaria)" pib_pc "Log(PIB per capita)" remu "Log(Remuneraciones)" D.tir "$\Delta$ (Log($1$ + Tasa de interés))"  ///
			 trend "Tendencia" _cons "Constante"  dum09 "Dummy 2009" dum20 "Dummy 2020" dum21 "Dummy 2021") order(trib pib_pc remu D.tir dum09 dum20 dum21 trend _cons)
			 
 eststo drop *
 drop dif_ecm money_modelo
 		
			
			
 *******************************************************************************	
 * Estimaciones de Informalidad
 *******************************************************************************
			 
* Se estiman tanto el circulante observado como el circulante legal a partir del modelo empírico

 qui prais money trib pib_pc remu d.tir trend dum09 dum20 dum21, vce(robust) ssesearch
 loc b0 = _b[_cons]
 loc b1 = _b[trib]
 loc b2 = _b[pib_pc]
 loc b3 = _b[remu]
 loc b4 = _b[d.tir]
 loc b5 = _b[trend]
 loc b6 = _b[dum09]
 loc b7 = _b[dum20]
 loc b8 = _b[dum21]

 gen circulante_total = `b0' + (`b1' * trib) + (`b2' * pib_pc) + (`b3' * remu) + (`b4' * d.tir) + (`b5' * trend) + (`b6' * dum09) + (`b7' * dum20) + (`b8' * dum21)
 gen circulante_formal = `b0' + (`b2' * pib_pc) + (`b3' * remu) + (`b4' * d.tir) + (`b5' * trend) + (`b6' * dum09) + (`b7' * dum20) + (`b8' * dum21)

 replace circulante_total  = exp(circulante_total)
 replace circulante_formal = exp(circulante_formal)

 gen circulante_informal = circulante_total - circulante_formal


* Se calcula la velocidad de las transacciones formales y se asume que es la misma velocidad de las transacciones informales
* Luego, la informalidad se calcula como velocidad * circulante informal

 gen velocidad = pib_nominal / circulante_total
 gen informalidad = (velocidad * circulante_informal) / pib_nominal
 
 qui sum informalidad 
 loc promedio: di %4.2fc r(mean) * 100
 tsline informalidad, xtitle("Año") ytitle("% del PIB") lwidth(medthick) text(0.42 2004 "Promedio = `promedio'%") ///
       ylabel(0.4(0.2)0.5 0.4 "40%" 0.42 "42%" 0.44 "44%" 0.46 "46%" 0.48 "48%" 0.5 "50%") $graphop 
 graph export "$out\informalidad_monetario.pdf", replace
 graph close _all
 
 
 