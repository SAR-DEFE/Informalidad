* DO file para elaborar gráficos con las estimaciones de informalidad

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
	 global var "egd monet wb_egd wb_mimic schneider"
 }
 else if "`c(username)'" == "Owner" {
	 global path "C:\Users\Owner\Desktop\Informalidad"
	 global out  "C:\Users\Owner\OneDrive - SAR\Notas técnicas y papers\Economía informal\out informalidad"
	 global graphop "legend(region(lcolor(none))) graphr(color(white))"
	 global var "egd monet wb_egd wb_mimic schneider"
 }
 
 * Paquetes necesario para reproducir el gráfico de matriz de correlaciones
 *ssc install heatplot, replace
 *ssc install palettes, replace
 *ssc install colrspace, replace
 
 
 * Importando los datos
 import delimited using "$path\base_eval_inf.csv", clear
 
 tsset fecha, yearly
 format ${var} %4.1fc
 
 
 * Gráficos
 twoway (scatter egd fecha, mcolor(blue%60) mlabel(egd) mlabposition(12) mlabsize(vsmall) mlabcolor(blue%60)) (line egd fecha, lc(blue%60)), ///
        $graphop legend(order(1 "Estimación EGD")) xtitle("Año") ytitle("% del PIB") xscale(titlegap(3)) yscale(titlegap(3)) ///
        ylabel(40(2)50 40 "40%" 42 "42%" 44 "44%" 46 "46%" 48 "48%" 50 "50%")
 graph export "$out\estimaciones_propias1.pdf", replace
 
 twoway (scatter egd fecha, mcolor(blue%60) mlabel(egd) mlabposition(12) mlabsize(vsmall) mlabcolor(blue%60)) (line egd fecha, lc(blue%60)) /// 
        (scatter monet fecha, mcolor(red%60)  mlabel(monet) mlabposition(12) mlabsize(vsmall) mlabcolor(red%60)) (line monet fecha, lc(red%60)), ///
        $graphop legend(order(1 "Estimación EGD" 3 "Estimación Circulante")) xtitle("Año") ytitle("% del PIB") xscale(titlegap(3)) yscale(titlegap(3)) ///
        ylabel(40(2)50 40 "40%" 42 "42%" 44 "44%" 46 "46%" 48 "48%" 50 "50%")
 graph export "$out\estimaciones_propias.pdf", replace
 
 twoway (connected egd fecha, 	mcolor(blue%60) msize(small) mlabcolor(blue%60) lc(blue%60)) /// 
        (connected monet fecha, mcolor(red%60) msize(small) mlabcolor(red%60) lc(red%60)) ///
		(line wb_egd fecha,     lc(green)) ///
		(line wb_mimic fecha,   lc(cyan)) ///
		(line schneider fecha,  lc(gold)), ///
        $graphop legend(row(2) order(1 "EGD" 2 "Circulante" 3 "WB EGD" 4 "WB MIMIC" 5 "Schneider (2018)")) xtitle("Año") ytitle("% del PIB") xscale(titlegap(3)) yscale(titlegap(3)) ///
        ylabel(36(4)52 36 "36%" 40 "40%" 44 "44%" 48 "48%" 52 "52%")
 graph export "$out\estimaciones_comparativas.pdf", replace
 
 
 * Mapa de calor de correlaciones
 qui correlate ${var}
 mat Correlación = r(C)
 
 heatplot Correlación, $graphop values(format(%9.2f)) color(hcl redblue, reverse intensity(0.1(0.2)1)) ///
          aspectratio(1) lower keylabels(, interval format(%9.2f)) cuts(0.55(0.05)1) ///
		  ylabel(1 "EGD" 2 "Circulante" 3 "WB EGD" 4 "WB MIMIC" 5 "Schneider (2018)", nogrid labsize(small)) ///
		  xlabel(1 "EGD" 2 "Circulante" 3 "WB EGD" 4 "WB MIMIC" 5 "Schneider (2018)", nogrid labsize(small) angle(45))
 graph export "$out\heatplot.pdf", replace
 
 
 * Tabla de momentos estadísticos
 eststo: qui estpost summ ${var}, detail
 est store sumario
 
 esttab sumario using "$out\sumario_informalidad", replace label booktabs nonum f noobs gap ///
	   coeflabel(egd "EGD" monet "Circulante" wb_egd "WB EGD" wb_mimic "WB MIMIC" schneider "Schneider (2018)")  ///
	   cells("mean(fmt(%20.2fc)) sd(fmt(%20.2fc)) min(fmt(%20.2fc)) p25(fmt(%20.2fc)) p50(fmt(%20.2fc)) p75(fmt(%20.2fc)) max(fmt(%20.2fc)) count(fmt(%20.0fc))") ///
	   collabels("Media" "Desv. Est." "Min" "25\%" "50\%" "75\%" "Max" "N° Obs.")
 
 
 