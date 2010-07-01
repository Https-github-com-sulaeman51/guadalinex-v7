/***************************************************************************
                 flfacturac.qs  -  description
                             -------------------
    begin                : lun abr 26 2004
    copyright            : (C) 2004 by InfoSiAL S.L.
    email                : mail@infosial.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

/** @file */ 

/** @class_declaration interna */
////////////////////////////////////////////////////////////////////////////
//// DECLARACION ///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//// INTERNA /////////////////////////////////////////////////////
class interna {
	var ctx:Object;
	function interna( context ) { this.ctx = context; }
	function beforeCommit_presupuestoscli(curPresupuesto:FLSqlCursor):Boolean {
		return this.ctx.interna_beforeCommit_presupuestoscli(curPresupuesto);
	}
	function beforeCommit_pedidoscli(curPedido:FLSqlCursor):Boolean {
		return this.ctx.interna_beforeCommit_pedidoscli(curPedido);
	}
	function beforeCommit_pedidosprov(curPedido:FLSqlCursor):Boolean {
		return this.ctx.interna_beforeCommit_pedidosprov(curPedido);
	}
	function beforeCommit_albaranescli(curAlbaran:FLSqlCursor):Boolean {
		return this.ctx.interna_beforeCommit_albaranescli(curAlbaran);
	}
	function beforeCommit_albaranesprov(curAlbaran:FLSqlCursor):Boolean {
		return this.ctx.interna_beforeCommit_albaranesprov(curAlbaran);
	}
	function beforeCommit_facturascli(curFactura:FLSqlCursor):Boolean {
		return this.ctx.interna_beforeCommit_facturascli(curFactura);
	}
	function beforeCommit_facturasprov(curFactura:FLSqlCursor):Boolean {
		return this.ctx.interna_beforeCommit_facturasprov(curFactura);
	}
	function afterCommit_facturascli(curFactura:FLSqlCursor):Boolean {
		return this.ctx.interna_afterCommit_facturascli(curFactura);
	}
	function afterCommit_facturasprov(curFactura:FLSqlCursor):Boolean {
		return this.ctx.interna_afterCommit_facturasprov(curFactura);
	}
	function afterCommit_lineasalbaranesprov(curLA:FLSqlCursor):Boolean {
		return this.ctx.interna_afterCommit_lineasalbaranesprov(curLA);
	}
	function afterCommit_lineasfacturasprov(curLF:FLSqlCursor):Boolean {
		return this.ctx.interna_afterCommit_lineasfacturasprov(curLF);
	}
	function afterCommit_lineaspedidoscli(curLA:FLSqlCursor):Boolean {
		return this.ctx.interna_afterCommit_lineaspedidoscli(curLA);
	}
	function afterCommit_lineasalbaranescli(curLA:FLSqlCursor):Boolean {
		return this.ctx.interna_afterCommit_lineasalbaranescli(curLA);
	}
	function afterCommit_lineasfacturascli(curLF:FLSqlCursor):Boolean {
		return this.ctx.interna_afterCommit_lineasfacturascli(curLF);
	}
}
//// INTERNA /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
class oficial extends interna {
	function oficial( context ) { interna( context ); }
	function obtenerHueco(codSerie:String, codEjercicio:String, tipo:String):Number {
		return this.ctx.oficial_obtenerHueco(codSerie, codEjercicio, tipo);
	}
	function establecerNumeroSecuencia(fN:String, value:Number):Number {
		return this.ctx.oficial_establecerNumeroSecuencia(fN, value);
	}
	function cerosIzquierda(numero:String, totalCifras:Number):String {
		return this.ctx.oficial_cerosIzquierda(numero, totalCifras);
	}
	function construirCodigo(codSerie:String, codEjercicio:String, numero:String):String {
		return this.ctx.oficial_construirCodigo(codSerie, codEjercicio, numero);
	}
	function siguienteNumero(codSerie:String, codEjercicio:String, fN:String):Number {
		return this.ctx.oficial_siguienteNumero(codSerie, codEjercicio, fN);
	}
	function agregarHueco(serie:String, ejercicio:String, numero:Number, fN:String):Boolean {
		return this.ctx.oficial_agregarHueco(serie, ejercicio, numero, fN);
	}
	function asientoBorrable(idAsiento:Number):Boolean {
		return this.ctx.oficial_asientoBorrable(idAsiento);
	}
	function generarAsientoFacturaCli(curFactura:FLSqlCursor):Boolean {
		return this.ctx.oficial_generarAsientoFacturaCli(curFactura);
	}
	function generarPartidasVenta(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array):Boolean {
		return this.ctx.oficial_generarPartidasVenta(curFactura, idAsiento, valoresDefecto);
	}
	function generarPartidasIVACli(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array, ctaCliente:Array):Boolean {
		return this.ctx.oficial_generarPartidasIVACli(curFactura, idAsiento, valoresDefecto, ctaCliente);
	}
	function generarPartidasIRPF(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array):Boolean {
		return this.ctx.oficial_generarPartidasIRPF(curFactura, idAsiento, valoresDefecto);
	}
	function generarPartidasRecFinCli(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array):Boolean {
		return this.ctx.oficial_generarPartidasRecFinCli(curFactura, idAsiento, valoresDefecto);
	}
	function generarPartidasIRPFProv(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array):Boolean {
		return this.ctx.oficial_generarPartidasIRPFProv(curFactura, idAsiento, valoresDefecto);
	}
	function generarPartidasRecFinProv(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array):Boolean {
		return this.ctx.oficial_generarPartidasRecFinProv(curFactura, idAsiento, valoresDefecto);
	}
	function generarPartidasCliente(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array, ctaCliente:Array):Boolean {
		return this.ctx.oficial_generarPartidasCliente(curFactura, idAsiento, valoresDefecto, ctaCliente);
	}
	function regenerarAsiento(curFactura:FLSqlCursor, valoresDefecto:Array):Array {
		return this.ctx.oficial_regenerarAsiento(curFactura, valoresDefecto);
	}
	function generarAsientoFacturaProv(curFactura:FLSqlCursor):Boolean {
		return this.ctx.oficial_generarAsientoFacturaProv(curFactura);
	}
	function generarPartidasCompra(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array, concepto:String):Boolean {
		return this.ctx.oficial_generarPartidasCompra(curFactura, idAsiento, valoresDefecto, concepto);
	}
	function generarPartidasIVAProv(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array, ctaProveedor:Array, concepto:String):Boolean {
		return this.ctx.oficial_generarPartidasIVAProv(curFactura, idAsiento, valoresDefecto, ctaProveedor, concepto);
	}
	function generarPartidasProveedor(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array, ctaProveedor:Array, concepto:String, sinIVA:Boolean):Boolean {
		return this.ctx.oficial_generarPartidasProveedor(curFactura, idAsiento, valoresDefecto, ctaProveedor, concepto, sinIVA);
	}
	function datosCtaEspecial(ctaEsp:String, codEjercicio:String):Array {
		return this.ctx.oficial_datosCtaEspecial(ctaEsp, codEjercicio);
	}
	function datosCtaIVA(tipo:String, codEjercicio:String, codImpuesto:String):Array {
		return this.ctx.oficial_datosCtaIVA(tipo, codEjercicio, codImpuesto);
	}
	function datosCtaVentas(codEjercicio:String, codSerie:String):Array {
		return this.ctx.oficial_datosCtaVentas(codEjercicio, codSerie);
	}
	function datosCtaCliente(curFactura:FLSqlCursor, valoresDefecto:Array):Array {
		return this.ctx.oficial_datosCtaCliente(curFactura, valoresDefecto);
	}
	function datosCtaProveedor(curFactura:FLSqlCursor, valoresDefecto:Array):Array {
		return this.ctx.oficial_datosCtaProveedor(curFactura, valoresDefecto);
	}
	function asientoFacturaAbonoCli(curFactura:FLSqlCursor, valoresDefecto:Array){
		return this.ctx.oficial_asientoFacturaAbonoCli(curFactura, valoresDefecto);
	}
	function asientoFacturaAbonoProv(curFactura:FLSqlCursor, valoresDefecto:Array){
		return this.ctx.oficial_asientoFacturaAbonoProv(curFactura, valoresDefecto);
	}
	function datosDocFacturacion(fecha:String, codEjercicio:String, tipoDoc:String):Array {
		return this.ctx.oficial_datosDocFacturacion(fecha, codEjercicio, tipoDoc);
	}
	function tieneIvaDocCliente(codSerie:String, codCliente:String):Boolean {
		return this.ctx.oficial_tieneIvaDocCliente(codSerie, codCliente);
	}
	function automataActivado():Boolean {
		return this.ctx.oficial_automataActivado();
	}
	function comprobarRegularizacion(curFactura:FLSqlCursor):Boolean {
		return this.ctx.oficial_comprobarRegularizacion(curFactura);
	}
	function recalcularHuecos(serie:String, ejercicio:String, fN:String):Boolean {
		return this.ctx.oficial_recalcularHuecos(serie, ejercicio, fN);
	}
	function mostrarTraza(codigo:String, tipo:String) {
		return this.ctx.oficial_mostrarTraza(codigo, tipo);
	}
	function datosPartidaFactura(curPartida:FLSqlCursor, curFactura:FLSqlCursor, tipo:String, concepto:String) {
		return this.ctx.oficial_datosPartidaFactura(curPartida, curFactura, tipo, concepto);
	}
	function eliminarAsiento(idAsiento:String):Boolean {
		return this.ctx.oficial_eliminarAsiento(idAsiento);
	}
	function siGenerarRecibosCli(curFactura:FLSqlCursor, masCampos:Array):Boolean {
		return this.ctx.oficial_siGenerarRecibosCli(curFactura, masCampos);
	}
	function validarIvaRecargoCliente(codCliente:String,id:Number,tabla:String,identificador:String):Boolean {
		return this.ctx.oficial_validarIvaRecargoCliente(codCliente,id,tabla,identificador);
	}
	function validarIvaRecargoProveedor(codProveedor:String,id:Number,tabla:String,identificador:String):Boolean {
		return this.ctx.oficial_validarIvaRecargoProveedor(codProveedor,id,tabla,identificador);
	}
}
//// OFICIAL /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////
class head extends oficial {
	function head( context ) { oficial ( context ); }
}
//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_declaration ifaceCtx */
/////////////////////////////////////////////////////////////////
//// INTERFACE  /////////////////////////////////////////////////
class ifaceCtx extends head {
	function ifaceCtx( context ) { head( context ); }
	function pub_cerosIzquierda(numero:String, totalCifras:Number):String {
		return this.cerosIzquierda(numero, totalCifras);
	}
	function pub_asientoBorrable(idAsiento:Number):Boolean {
		return this.asientoBorrable(idAsiento);
	}
	function pub_regenerarAsiento(curFactura:FLSqlCursor, valoresDefecto:Array):Array {
		return this.regenerarAsiento(curFactura, valoresDefecto);
	}
	function pub_datosCtaEspecial(ctaEsp:String, codEjercicio:String):Array {
		return this.datosCtaEspecial(ctaEsp, codEjercicio);
	}
	function pub_siguienteNumero(codSerie:String, codEjercicio:String, fN:String):Number {
		return this.siguienteNumero(codSerie, codEjercicio, fN);
	}
	function pub_construirCodigo(codSerie:String, codEjercicio:String, numero:String):String {
		return this.construirCodigo(codSerie, codEjercicio, numero);
	}
	function pub_agregarHueco(serie:String, ejercicio:String, numero:Number, fN:String):Boolean {
		return this.agregarHueco(serie, ejercicio, numero, fN);
	}
	function pub_datosDocFacturacion(fecha:String, codEjercicio:String, tipoDoc:String):Array {
		return this.datosDocFacturacion(fecha, codEjercicio, tipoDoc);
	}
	function pub_tieneIvaDocCliente(codSerie:String, codCliente:String):Boolean {
		return this.tieneIvaDocCliente(codSerie, codCliente);
	}
	function pub_automataActivado():Boolean {
		return this.automataActivado();
	}
	function pub_generarAsientoFacturaCli(curFactura:FLSqlCursor):Boolean {
		return this.generarAsientoFacturaCli(curFactura);
	}
	function pub_generarAsientoFacturaProv(curFactura:FLSqlCursor):Boolean {
		return this.generarAsientoFacturaProv(curFactura);
	}
	function pub_mostrarTraza(codigo:String, tipo:String) {
		return this.mostrarTraza(codigo, tipo);
	}
	function pub_eliminarAsiento(idAsiento:String):Boolean {
		return this.eliminarAsiento(idAsiento);
	}
	function pub_validarIvaRecargoCliente(codCliente:String,id:Number,tabla:String,identificador:String):Boolean {
		return this.validarIvaRecargoCliente(codCliente,id,tabla,identificador);
	}
	function pub_validarIvaRecargoProveedor(codProveedor:String,id:Number,tabla:String,identificador:String):Boolean {
		return this.validarIvaRecargoProveedor(codProveedor,id,tabla,identificador);
	}
}

const iface = new ifaceCtx( this );
//// INTERFACE  /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition interna */
////////////////////////////////////////////////////////////////////////////
//// DEFINICION ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//// INTERNA /////////////////////////////////////////////////////
/** \C 
Se calcula el número del pedido como el siguiente de la secuencia asociada a su ejercicio y serie. 

Se actualiza el estado del pedido.

Si el pedido está servido parcialmente y se quiere borrar, no se permite borrarlo o se dá la opción de cancelar lo pendiente de servir.
\end */
function interna_beforeCommit_pedidoscli(curPedido:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil();
	var numero:String;
	
	switch (curPedido.modeAccess()) {
		case curPedido.Insert: {
			if (!flfactppal.iface.pub_clienteActivo(curPedido.valueBuffer("codcliente"), curPedido.valueBuffer("fecha")))
				return false;
			if (curPedido.valueBuffer("numero") == 0) {
				numero = this.iface.siguienteNumero(curPedido.valueBuffer("codserie"), curPedido.valueBuffer("codejercicio"), "npedidocli");
				if (!numero)
					return false;
				curPedido.setValueBuffer("numero", numero);
				curPedido.setValueBuffer("codigo", formpedidoscli.iface.pub_commonCalculateField("codigo", curPedido));
			}
			break;
		}
		case curPedido.Edit: {
			if (!flfactppal.iface.pub_clienteActivo(curPedido.valueBuffer("codcliente"), curPedido.valueBuffer("fecha")))
				return false;
			if (curPedido.valueBuffer("servido") == "Parcial") {
				var estado:String = formRecordlineasalbaranescli.iface.pub_obtenerEstadoPedido(curPedido.valueBuffer("idpedido"));
				if (estado == "Sí") {
					curPedido.setValueBuffer("servido", estado);
					curPedido.setValueBuffer("editable", false);
				}
			}
			break;
		}
		case curPedido.Del: {
			if (curPedido.valueBuffer("servido") == "Parcial") {
				MessageBox.warning(util.translate("scripts", "No se puede eliminar un pedido servido parcialmente.\nDebe borrar antes el albarán relacionado."), MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton);
				return false;
			}
			break;
		}
	}
	
	return true;
}

/** \C 
Se calcula el número del pedido como el siguiente de la secuencia asociada a su ejercicio y serie. 

Se actualiza el estado del pedido.

Si el pedido está servido parcialmente y se quiere borrar, no se permite borrarlo o se dá la opción de cancelar lo pendiente de servir.
\end */
function interna_beforeCommit_pedidosprov(curPedido:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil();
	var numero:String;
	
	switch (curPedido.modeAccess()) {
		case curPedido.Insert: {
			if (curPedido.valueBuffer("numero") == 0) {
				numero = this.iface.siguienteNumero(curPedido.valueBuffer("codserie"), curPedido.valueBuffer("codejercicio"), "npedidoprov");
				if (!numero)
					return false;
				curPedido.setValueBuffer("numero", numero);
				curPedido.setValueBuffer("codigo", formpedidosprov.iface.pub_commonCalculateField("codigo", curPedido));
			}
			break;
		}
		case curPedido.Edit: {
			if (curPedido.valueBuffer("servido") == "Parcial") {
				var estado:String = formRecordlineasalbaranesprov.iface.pub_obtenerEstadoPedido(curPedido.valueBuffer("idpedido"));
				if (estado == "Sí") {
					curPedido.setValueBuffer("servido", estado);
					curPedido.setValueBuffer("editable", false);
					if (sys.isLoadedModule("flcolaproc")) {
						if (!flfactppal.iface.pub_lanzarEvento(curPedido, "pedidoProvAlbaranado"))
							return false;
					}
				}
			}
			break;
		}
		case curPedido.Del: {
			if (curPedido.valueBuffer("servido") == "Parcial") {
				MessageBox.warning(util.translate("scripts", "No se puede eliminar un pedido servido parcialmente.\nDebe borrar antes el albarán relacionado."), MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton);
				return false;
			}
			break;
		}
	}
	return true;
}

/* \C En el caso de que el módulo de contabilidad esté cargado y activado, genera o modifica el asiento contable correspondiente a la factura a cliente.
\end */
function interna_beforeCommit_facturascli(curFactura:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil();
	var numero:String;
	
	if (curFactura.valueBuffer("deabono") == true) {
		if (!curFactura.valueBuffer("idfacturarect")){
			MessageBox.warning(util.translate("scripts", "Debe seleccionar la factura que desea abonar"),MessageBox.Ok, MessageBox.NoButton,MessageBox.NoButton);
			return false;
		}
		if (util.sqlSelect("facturascli", "idfacturarect", "idfacturarect = " + curFactura.valueBuffer("idfacturarect") + " AND idfactura <> " + curFactura.valueBuffer("idfactura"))) {
			MessageBox.warning(util.translate("scripts", "La factura ") +  util.sqlSelect("facturascli", "codigo", "idfactura = " + curFactura.valueBuffer("idfacturarect"))  + util.translate("scripts", " ya está abonada"),MessageBox.Ok, MessageBox.NoButton,MessageBox.NoButton);
			return false;
		}
	}
	
	
	switch (curFactura.modeAccess()) {
		case curFactura.Insert: {
			if (!flfactppal.iface.pub_clienteActivo(curFactura.valueBuffer("codcliente"), curFactura.valueBuffer("fecha")))
				return false;
			if (curFactura.valueBuffer("numero") == 0) {
				this.iface.recalcularHuecos( curFactura.valueBuffer("codserie"), curFactura.valueBuffer("codejercicio"), "nfacturacli" );
				numero = this.iface.siguienteNumero(curFactura.valueBuffer("codserie"), curFactura.valueBuffer("codejercicio"), "nfacturacli");
				if (!numero)
					return false;
				curFactura.setValueBuffer("numero", numero);
				curFactura.setValueBuffer("codigo", formfacturascli.iface.pub_commonCalculateField("codigo", curFactura));
			}
			break;
		}
		case curFactura.Edit: {
			if (!flfactppal.iface.pub_clienteActivo(curFactura.valueBuffer("codcliente"), curFactura.valueBuffer("fecha")))
				return false;
			break;
		}
	}

	if (curFactura.modeAccess() == curFactura.Insert || curFactura.modeAccess() == curFactura.Edit) {
		if (util.sqlSelect("facturascli", "idfactura", "codejercicio = '" + curFactura.valueBuffer("codejercicio") + "' AND codserie = '" + curFactura.valueBuffer("codserie") + "' AND numero = '" + curFactura.valueBuffer("numero") + "' AND idfactura <> " + curFactura.valueBuffer("idfactura"))) {
			numero = this.iface.siguienteNumero(curFactura.valueBuffer("codserie"), curFactura.valueBuffer("codejercicio"), "nfacturacli");
			if (!numero)
				return false;
			curFactura.setValueBuffer("numero", numero);
			curFactura.setValueBuffer("codigo", formfacturascli.iface.pub_commonCalculateField("codigo", curFactura));
		}
	}

	if (!formRecordfacturascli.iface.pub_actualizarLineasIva(curFactura))
		return false;

	if (sys.isLoadedModule("flcontppal") && flfactppal.iface.pub_valorDefectoEmpresa("contintegrada")) {
		if (this.iface.generarAsientoFacturaCli(curFactura) == false)
			return false;
	}
	
	return true;
}

/* \C En el caso de que el módulo de contabilidad esté cargado y activado, genera o modifica el asiento contable correspondiente a la factura a proveedor.
\end */
function interna_beforeCommit_facturasprov(curFactura:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil();
	var numero:String;
	
	if (curFactura.valueBuffer("deabono") == true) {
		if (!curFactura.valueBuffer("idfacturarect")){
			MessageBox.warning(util.translate("scripts", "Debe seleccionar la factura que desea abonar"),MessageBox.Ok, MessageBox.NoButton,MessageBox.NoButton);
			return false;
		}
		if (util.sqlSelect("facturasprov", "idfacturarect", "idfacturarect = " + curFactura.valueBuffer("idfacturarect") + " AND idfactura <> " + curFactura.valueBuffer("idfactura"))) {
			MessageBox.warning(util.translate("scripts", "La factura ") +  util.sqlSelect("facturasprov", "codigo", "idfactura = " + curFactura.valueBuffer("idFacturarect"))  + util.translate("scripts", " ya está abonada"),MessageBox.Ok, MessageBox.NoButton,MessageBox.NoButton);
			return false;
		}
	}
	
	if (curFactura.modeAccess() == curFactura.Insert) {
		if (curFactura.valueBuffer("numero") == 0) {
			this.iface.recalcularHuecos( curFactura.valueBuffer("codserie"), curFactura.valueBuffer("codejercicio"), "nfacturaprov" );
			numero = this.iface.siguienteNumero(curFactura.valueBuffer("codserie"), curFactura.valueBuffer("codejercicio"), "nfacturaprov");
			if (!numero)
				return false;
			curFactura.setValueBuffer("numero", numero);
			curFactura.setValueBuffer("codigo", formfacturasprov.iface.pub_commonCalculateField("codigo", curFactura));
		}
	}

	if (curFactura.modeAccess() == curFactura.Insert || curFactura.modeAccess() == curFactura.Edit) {
		if (util.sqlSelect("facturasprov", "idfactura", "codejercicio = '" + curFactura.valueBuffer("codejercicio") + "' AND codserie = '" + curFactura.valueBuffer("codserie") + "' AND numero = '" + curFactura.valueBuffer("numero") + "' AND idfactura <> " + curFactura.valueBuffer("idfactura"))) {
			numero = this.iface.siguienteNumero(curFactura.valueBuffer("codserie"), curFactura.valueBuffer("codejercicio"), "nfacturaprov");
			if (!numero)
				return false;
			curFactura.setValueBuffer("numero", numero);
			curFactura.setValueBuffer("codigo", formfacturasprov.iface.pub_commonCalculateField("codigo", curFactura));
		}
	}

	if (!formRecordfacturasprov.iface.pub_actualizarLineasIva(curFactura))
		return false;

	if (sys.isLoadedModule("flcontppal") && flfactppal.iface.pub_valorDefectoEmpresa("contintegrada")) {
		if (this.iface.generarAsientoFacturaProv(curFactura) == false)
			return false;
	}
	return true;
}


/* \C Se calcula el número del albarán como el siguiente de la secuencia asociada a su ejercicio y serie. 
Se recalcula el estado de los pedidos asociados al albarán
\end */
function interna_beforeCommit_albaranescli(curAlbaran:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil();
	var numero:String;
	
	switch (curAlbaran.modeAccess()) {
		case curAlbaran.Insert: {
			if (!flfactppal.iface.pub_clienteActivo(curAlbaran.valueBuffer("codcliente"), curAlbaran.valueBuffer("fecha")))
				return false;
			if (curAlbaran.valueBuffer("numero") == 0) {
				numero = this.iface.siguienteNumero(curAlbaran.valueBuffer("codserie"), curAlbaran.valueBuffer("codejercicio"), "nalbarancli");
				if (!numero)
					return false;
				curAlbaran.setValueBuffer("numero", numero);
				curAlbaran.setValueBuffer("codigo", formalbaranescli.iface.pub_commonCalculateField("codigo", curAlbaran));
			}
			break;
		}
		case curAlbaran.Edit: {
			if (!flfactppal.iface.pub_clienteActivo(curAlbaran.valueBuffer("codcliente"), curAlbaran.valueBuffer("fecha")))
				return false;
			break;
		}
	}
	
	var query:FLSqlQuery = new FLSqlQuery();
	query.setTablesList("lineasalbaranescli");
	query.setSelect("idlineapedido, idpedido, referencia, idalbaran, cantidad");
	query.setFrom("lineasalbaranescli");
	query.setWhere("idalbaran = " + curAlbaran.valueBuffer("idalbaran") + " AND idlineapedido <> 0 ORDER BY idpedido");
	try { query.setForwardOnly( true ); } catch (e) {}
	query.exec();
	var idPedido:String = 0;
	while (query.next()) {
		if (!formRecordlineasalbaranescli.iface.pub_actualizarLineaPedido(query.value(0), query.value(1), query.value(2), query.value(3), query.value(4)))
			return false;
			
		if (idPedido != query.value(1)) {
			if (!formRecordlineasalbaranescli.iface.pub_actualizarEstadoPedido(query.value(1), curAlbaran))
				return false;
		}
		idPedido = query.value(1)
	}
	return true;
}

/* \C Se calcula el número del albarán como el siguiente de la secuencia asociada a su ejercicio y serie. 

Se recalcula el estado de los pedidos asociados al albarán
\end */
function interna_beforeCommit_albaranesprov(curAlbaran:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil();
	var numero:String;
	
	if (curAlbaran.modeAccess() == curAlbaran.Insert) {
		if (curAlbaran.valueBuffer("numero") == 0) {
			numero = this.iface.siguienteNumero(curAlbaran.valueBuffer("codserie"), curAlbaran.valueBuffer("codejercicio"), "nalbaranprov");
			if (!numero)
				return false;
			curAlbaran.setValueBuffer("numero", numero);
			curAlbaran.setValueBuffer("codigo", formalbaranesprov.iface.pub_commonCalculateField("codigo", curAlbaran));
		}
	}
	var query:FLSqlQuery = new FLSqlQuery();
	query.setTablesList("lineasalbaranesprov");
	query.setSelect("idlineapedido, idpedido, referencia, idalbaran, cantidad");
	query.setFrom("lineasalbaranesprov");
	query.setWhere("idalbaran = " + curAlbaran.valueBuffer("idalbaran") + " AND idlineapedido <> 0 ORDER BY idpedido");
	try { query.setForwardOnly( true ); } catch (e) {}
	query.exec();
	var idPedido:String = 0;
	while (query.next()) {
		if (!formRecordlineasalbaranesprov.iface.pub_actualizarLineaPedido(query.value(0), query.value(1), query.value(2), query.value(3), query.value(4)))
			return false;
		if (idPedido != query.value(1)) {
			if (!formRecordlineasalbaranesprov.iface.pub_actualizarEstadoPedido(query.value(1), curAlbaran))
				return false;
		}
		idPedido = query.value(1);
	}
	
	return true;
}

/* \C Se calcula el número del presupuesto como el siguiente de la secuencia asociada a su ejercicio y serie. 
\end */
function interna_beforeCommit_presupuestoscli(curPresupuesto:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil();
	var numero:String;
	
	switch (curPresupuesto.modeAccess()) {
		case curPresupuesto.Insert: {
			if (!flfactppal.iface.pub_clienteActivo(curPresupuesto.valueBuffer("codcliente"), curPresupuesto.valueBuffer("fecha")))
				return false;
			if (curPresupuesto.valueBuffer("numero") == 0) {
				numero = this.iface.siguienteNumero(curPresupuesto.valueBuffer("codserie"), curPresupuesto.valueBuffer("codejercicio"), "npresupuestocli");
				if (!numero)
					return false;
				curPresupuesto.setValueBuffer("numero", numero);
				curPresupuesto.setValueBuffer("codigo", formpresupuestoscli.iface.pub_commonCalculateField("codigo", curPresupuesto));
			}
			break;
		}
		case curPresupuesto.Edit: {
			if (!flfactppal.iface.pub_clienteActivo(curPresupuesto.valueBuffer("codcliente"), curPresupuesto.valueBuffer("fecha")))
				return false;
			break;
		}
	}
	
	return true;
}

/* \C En el caso de que el módulo de tesorería esté cargado, genera o modifica los recibos correspondientes a la factura.

En el caso de que el módulo pincipal de contabilidad esté cargado y activado, y que la acción a realizar sea la de borrado de la factura, borra el asiento contable correspondiente.
\end */
function interna_afterCommit_facturascli(curFactura:FLSqlCursor):Boolean
{
	if (curFactura.modeAccess() == curFactura.Del) {
		if (!this.iface.agregarHueco(curFactura.valueBuffer("codserie"), curFactura.valueBuffer("codejercicio"), curFactura.valueBuffer("numero"), "nfacturacli"))
			return false;
	}
	
	var util:FLUtil = new FLUtil();
	
	if (sys.isLoadedModule("flfactteso") && curFactura.valueBuffer("tpv") == false) {
		if (curFactura.modeAccess() == curFactura.Insert || curFactura.modeAccess() == curFactura.Edit) {
			if (this.iface.siGenerarRecibosCli(curFactura))
				if (flfactteso.iface.pub_regenerarRecibosCli(curFactura) == false)
					return false;
		}
		if (curFactura.modeAccess() == curFactura.Del) {
			flfactteso.iface.pub_actualizarRiesgoCliente(curFactura.valueBuffer("codcliente"));
		}
	}

	if (sys.isLoadedModule("flcontppal") && flfactppal.iface.pub_valorDefectoEmpresa("contintegrada")) {
		switch (curFactura.modeAccess()) {
			case curFactura.Del: {
				if (!this.iface.eliminarAsiento(curFactura.valueBuffer("idasiento")))
					return false;
				break;
			}
			case curFactura.Edit: {
				if (curFactura.valueBuffer("nogenerarasiento")) {
					var idAsientoAnterior:String = curFactura.valueBufferCopy("idasiento");
					if (idAsientoAnterior && idAsientoAnterior != "") {
						if (!this.iface.eliminarAsiento(idAsientoAnterior))
							return false;
					}
				}
				break;
			}
		}
	}
	
	return true;
}

/* \C En el caso de que el módulo pincipal de contabilidad esté cargado y activado, y que la acción a realizar sea la de borrado de la factura, borra el asiento contable correspondiente.
\end */
function interna_afterCommit_facturasprov(curFactura:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil();
	if (sys.isLoadedModule("flfactteso")) {
		if (curFactura.modeAccess() == curFactura.Insert || curFactura.modeAccess() == curFactura.Edit) {
			if (curFactura.valueBuffer("total") != curFactura.valueBufferCopy("total")
				|| curFactura.valueBuffer("codproveedor") != curFactura.valueBufferCopy("codproveedor")
				|| curFactura.valueBuffer("codpago") != curFactura.valueBufferCopy("codpago")
				|| curFactura.valueBuffer("fecha") != curFactura.valueBufferCopy("fecha")) {
				if (flfactteso.iface.pub_regenerarRecibosProv(curFactura) == false)
					return false;
			}
		}
	}

	if (sys.isLoadedModule("flcontppal") && flfactppal.iface.pub_valorDefectoEmpresa("contintegrada")) {
		switch (curFactura.modeAccess()) {
			case curFactura.Del: {
				if (!this.iface.eliminarAsiento(curFactura.valueBuffer("idasiento")))
					return false;
				break;
			}
			case curFactura.Edit: {
				if (curFactura.valueBuffer("nogenerarasiento")) {
					var idAsientoAnterior:String = curFactura.valueBufferCopy("idasiento");
					if (idAsientoAnterior && idAsientoAnterior != "") {
						if (!this.iface.eliminarAsiento(idAsientoAnterior))
							return false;
					}
				}
				break;
			}
		}
	}
	return true;
}

/** \C
Actualización del stock correspondiente al artículo seleccionado en la línea
\end */
function interna_afterCommit_lineasalbaranesprov(curLA:FLSqlCursor):Boolean
{
	if (sys.isLoadedModule("flfactalma")) 
		if (!flfactalma.iface.pub_controlStockAlbaranesProv(curLA))
			return false;
	
	return true;
}

/** \C
En el caso de que la factura no sea automática (no provenga de un albarán), realiza la actualización del stock correspondiente al artículo seleccionado en la línea.

Actualiza también el coste medio de los artículos afectados por el cambio.
\end */
function interna_afterCommit_lineasfacturasprov(curLF:FLSqlCursor):Boolean
{
	if (sys.isLoadedModule("flfactalma")) {
		var util:FLUtil = new FLUtil();
		switch(curLF.modeAccess()) {
			case curLF.Edit:
				if (curLF.valueBuffer("referencia") != curLF.valueBufferCopy("referencia"))
					flfactalma.iface.pub_cambiarCosteMedio(curLF.valueBufferCopy("referencia"));
			case curLF.Insert:
			case curLF.Del:
					flfactalma.iface.pub_cambiarCosteMedio(curLF.valueBuffer("referencia"));
			break;
		}
		
		if (!flfactalma.iface.pub_controlStockFacturasProv(curLF))
			return false;
	}
	return true;
}

/** \C
Actualiza el stock correspondiente al artículo seleccionado en la línea si el sistema
está configurado para ello
\end */
function interna_afterCommit_lineaspedidoscli(curLP:FLSqlCursor):Boolean
{
 	if (sys.isLoadedModule("flfactalma"))
// 	if (sys.isLoadedModule("flfactalma") && flfactppal.iface.pub_valorDefectoEmpresa("stockpedidos")) 
		if (!flfactalma.iface.pub_controlStockPedidosCli(curLP))
			return false;
	
	return true;
}

/** \C
Si la línea de albarán no proviene de una línea de pedido, realiza la actualización del stock correspondiente al artículo seleccionado en la línea
\end */
function interna_afterCommit_lineasalbaranescli(curLA:FLSqlCursor):Boolean
{
	if (sys.isLoadedModule("flfactalma")) 
		if (!flfactalma.iface.pub_controlStockAlbaranesCli(curLA))
			return false;
	
	return true;
}

/** \C
En el caso de que la factura no sea automática (no provenga de un albarán), realiza la actualización del stock correspondiente al artículo seleccionado en la línea
\end */
function interna_afterCommit_lineasfacturascli(curLF:FLSqlCursor):Boolean
{
	if (sys.isLoadedModule("flfactalma")) 
		if (!flfactalma.iface.pub_controlStockFacturasCli(curLF))
			return false;
	
	return true;
}
//// INTERNA /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
/** \D
Obtiene el primer hueco de la tabla de huecos (documentos de facturación que han sido borrados y han dejado su código disponible para volver a ser usado)
@param codSerie: Código de serie del documento
@param codEjercicio: Código de ejercicio del documento
@param tipo: Tipo de documento (factura a cliente, a proveedor)
@return Número correspondiente al primer hueco encontrado (0 si no se encuentra ninguno)
\end */
function oficial_obtenerHueco(codSerie:String, codEjercicio:String, tipo:String):Number
{
	var cursorHuecos:FLSqlCursor = new FLSqlCursor("huecos");
	var numHueco:Number = 0;
	cursorHuecos.select("upper(codserie)='" + codSerie + "' AND upper(codejercicio)='" + codEjercicio + "' AND upper(tipo)='" + tipo + "' ORDER BY numero;");
	if (cursorHuecos.next()) {
		numHueco = cursorHuecos.valueBuffer("numero");
		cursorHuecos.setActivatedCheckIntegrity(false);
		cursorHuecos.setModeAccess(cursorHuecos.Del);
		cursorHuecos.refreshBuffer();
		cursorHuecos.commitBuffer();
	}
	return numHueco;
}

function oficial_establecerNumeroSecuencia(fN:String, value:Number):Number
{
	return (parseFloat(value) + 1);
}

/** \D
Rellena un string con ceros a la izquierda hasta completar la logitud especificada
@param numero: String que contiene el número
@param totalCifras: Longitud a completar
\end */
function oficial_cerosIzquierda(numero:String, totalCifras:Number):String
{
	var ret:String = numero.toString();
	var numCeros:Number = totalCifras - ret.length;
	for ( ; numCeros > 0 ; --numCeros)
		ret = "0" + ret;
	return ret;
}

function oficial_construirCodigo(codSerie:String, codEjercicio:String, numero:String):String
{
	return this.iface.cerosIzquierda(codEjercicio, 4) +
		this.iface.cerosIzquierda(codSerie, 2) +
		this.iface.cerosIzquierda(numero, 6);
}

/** \D
Obtiene el siguiente número de la secuencia de documentos
@param codSerie: Código de serie del documento
@param codEjercicio: Código de ejercicio del documento
@param fN: Tipo de documento (factura a cliente, a proveedor, albarán, etc.)
@return Número correspondiente al siguiente documento en la serie o false si hay error
\end */
function oficial_siguienteNumero(codSerie:String, codEjercicio:String, fN:String):Number
{
	var numero:Number;
	var util:FLUtil = new FLUtil;
	var cursorSecuencias:FLSqlCursor = new FLSqlCursor("secuenciasejercicios");

	cursorSecuencias.setContext(this);
	cursorSecuencias.setActivatedCheckIntegrity(false);
	cursorSecuencias.select("upper(codserie)='" + codSerie + "' AND upper(codejercicio)='" + codEjercicio + "';");
	if (cursorSecuencias.next()) {
		if (fN == "nfacturaprov") {
			var numeroHueco:Number = this.iface.obtenerHueco(codSerie, codEjercicio, "FP");
			if (numeroHueco != 0) {
				cursorSecuencias.setActivatedCheckIntegrity(true);
				return numeroHueco;
			}
		}
		if (fN == "nfacturacli") {
			var numeroHueco:Number = this.iface.obtenerHueco(codSerie, codEjercicio, "FC");
			if (numeroHueco != 0) {
				cursorSecuencias.setActivatedCheckIntegrity(true);
				return numeroHueco;
			}
		}

		/** \C
		Para minimizar bloqueos las secuencias se han separado en distintos registros de otra tabla
		llamada secuencias
		\end */
		var cursorSecs:FLSqlCursor = new FLSqlCursor( "secuencias" );
		cursorSecs.setContext( this );
		cursorSecs.setActivatedCheckIntegrity( false );
		/** \C
		Si el registro no existe lo crea inicializandolo con su antiguo valor del campo correspondiente
		en la tabla secuenciasejercicios.
		\end */
		var idSec:Number = cursorSecuencias.valueBuffer( "id" );
		cursorSecs.select( "id=" + idSec + " AND nombre='" + fN + "'" );
		if ( !cursorSecs.next() ) {
			numero = cursorSecuencias.valueBuffer(fN);
			cursorSecs.setModeAccess( cursorSecs.Insert );
			cursorSecs.refreshBuffer();
			cursorSecs.setValueBuffer( "id", idSec );
			cursorSecs.setValueBuffer( "nombre", fN );
			cursorSecs.setValueBuffer( "valor", this.iface.establecerNumeroSecuencia( fN, numero ) );
			cursorSecs.commitBuffer();
		} else {
			cursorSecs.setModeAccess( cursorSecs.Edit );
			cursorSecs.refreshBuffer();
			if ( !cursorSecs.isNull( "valorout" ) )
				numero = cursorSecs.valueBuffer( "valorout" );
			else
				numero = cursorSecs.valueBuffer( "valor" );
			cursorSecs.setValueBuffer( "valorout", this.iface.establecerNumeroSecuencia( fN, numero ) );		
			cursorSecs.commitBuffer();
		}
		cursorSecs.setActivatedCheckIntegrity( true );
	} else {
		/** \C
		Si la serie no existe para el ejercicio actual se consultará al usuario si la quiere crear
		\end */
		var res:Number = MessageBox.warning(util.translate("scripts", "La serie ") + codSerie + util.translate("scripts"," no existe para el ejercicio ") + codEjercicio + util.translate("scripts",".\n¿Desea crearla?"), MessageBox.Yes,MessageBox.No);
		if (res != MessageBox.Yes) {
			cursorSecuencias.setActivatedCheckIntegrity(true);
			return false;
		}
		cursorSecuencias.setModeAccess(cursorSecuencias.Insert);
		cursorSecuencias.refreshBuffer();
		cursorSecuencias.setValueBuffer("codserie", codSerie);
		cursorSecuencias.setValueBuffer("codejercicio", codEjercicio);
		numero = "1";
		cursorSecuencias.setValueBuffer(fN, "2");
		if (!cursorSecuencias.commitBuffer()) {
			cursorSecuencias.setActivatedCheckIntegrity(true);
			return false;
		}
	}
	cursorSecuencias.setActivatedCheckIntegrity(true);
	return numero;
}

/** \D
Agrega un hueco a la tabla de huecos
@param serie: Código de serie del documento
@param ejercicio: Código de ejercicio del documento
@param numero: Número del documento
@param fN: Tipo de documento (factura a cliente, a proveedor, albarán, etc.)
@return true si el hueco se inserta correctamente o false si hay error
\end */
function oficial_agregarHueco(serie:String, ejercicio:String, numero:Number, fN:String):Boolean
{
	return this.iface.recalcularHuecos( serie, ejercicio, fN );
}

/* \D Indica si el asiento asociado a la factura puede o no regenerarse, según pertenezca a un ejercicio abierto o cerrado
@param idAsiento: Identificador del asiento
@return True: Asiento borrable, False: Asiento no borrable
\end */
function oficial_asientoBorrable(idAsiento:Number):Boolean
{
	var util:FLUtil = new FLUtil();
	var qryEjerAsiento:FLSqlQuery = new FLSqlQuery();
	qryEjerAsiento.setTablesList("ejercicios,co_asientos");
	qryEjerAsiento.setSelect("e.estado");
	qryEjerAsiento.setFrom("co_asientos a INNER JOIN ejercicios e" +
			" ON a.codejercicio = e.codejercicio");
	qryEjerAsiento.setWhere("a.idasiento = " + idAsiento);
	try { qryEjerAsiento.setForwardOnly( true ); } catch (e) {}

	if (!qryEjerAsiento.exec())
		return false;

	if (!qryEjerAsiento.next())
		return false;

	if (qryEjerAsiento.value(0) != "ABIERTO") {
		MessageBox.critical(util.translate("scripts",
		"No puede realizarse la modificación porque el asiento contable correspondiente pertenece a un ejercicio cerrado"),
				MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton);
		return false;
	}

	return true;
}

/** \U Genera o regenera el asiento correspondiente a una factura de cliente
@param	curFactura: Cursor con los datos de la factura
@return	VERDADERO si no hay error. FALSO en otro caso
\end */
function oficial_generarAsientoFacturaCli(curFactura:FLSqlCursor):Boolean
{
	if (curFactura.modeAccess() != curFactura.Insert && curFactura.modeAccess() != curFactura.Edit)
		return true;

	var util:FLUtil = new FLUtil;
	if (curFactura.valueBuffer("nogenerarasiento")) {
		curFactura.setNull("idasiento");
		return true;
	}

	if (!this.iface.comprobarRegularizacion(curFactura))
		return false;

	var datosAsiento:Array = [];
	var valoresDefecto:Array;
	valoresDefecto["codejercicio"] = curFactura.valueBuffer("codejercicio");
	valoresDefecto["coddivisa"] = flfactppal.iface.pub_valorDefectoEmpresa("coddivisa");

	datosAsiento = this.iface.regenerarAsiento(curFactura, valoresDefecto);
	if (datosAsiento.error == true)
		return false;

	var ctaCliente = this.iface.datosCtaCliente(curFactura, valoresDefecto);
	if (ctaCliente.error != 0)
		return false;

	if (!this.iface.generarPartidasCliente(curFactura, datosAsiento.idasiento, valoresDefecto, ctaCliente))
		return false;

	if (!this.iface.generarPartidasIRPF(curFactura, datosAsiento.idasiento, valoresDefecto))
		return false;

	if (!this.iface.generarPartidasIVACli(curFactura, datosAsiento.idasiento, valoresDefecto, ctaCliente))
		return false;

	if (!this.iface.generarPartidasRecFinCli(curFactura, datosAsiento.idasiento, valoresDefecto))
		return false;				
			
	if (!this.iface.generarPartidasVenta(curFactura, datosAsiento.idasiento, valoresDefecto))
		return false;
    
	curFactura.setValueBuffer("idasiento", datosAsiento.idasiento);
	
	if (curFactura.valueBuffer("deabono") == true)
		if (!this.iface.asientoFacturaAbonoCli(curFactura, valoresDefecto))
			return false;

	if (!flcontppal.iface.pub_comprobarAsiento(datosAsiento.idasiento))
		return false;

	return true;
}

/** \D Genera la parte del asiento de factura correspondiente a la subcuenta de ventas
@param	curFactura: Cursor de la factura
@param	idAsiento: Id del asiento asociado
@param	valoresDefecto: Array con los valores por defecto de ejercicio y divisa
@return	VERDADERO si no hay error, FALSO en otro caso
\end */
function oficial_generarPartidasVenta(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array):Boolean
{
		var util:FLUtil = new FLUtil();
		var ctaVentas:Array = this.iface.datosCtaVentas(valoresDefecto.codejercicio, curFactura.valueBuffer("codserie"));
		if (ctaVentas.error != 0) {
			MessageBox.warning(util.translate("scripts", "No se ha encontrado una subcuenta de ventas para esta factura."), MessageBox.Ok, MessageBox.NoButton);
			return false;
		}
		var haber:Number = 0;
		var haberME:Number = 0;
		var monedaSistema:Boolean = (valoresDefecto.coddivisa == curFactura.valueBuffer("coddivisa"));
		if (monedaSistema) {
				haber = curFactura.valueBuffer("neto");
				haberME = 0;
		} else {
				haber = util.sqlSelect("co_partidas", "SUM(debe - haber)", "idasiento = " + idAsiento);
				haberME = curFactura.valueBuffer("neto");
		}
		haber = util.roundFieldValue(haber, "co_partidas", "haber");
		haberME = util.roundFieldValue(haberME, "co_partidas", "haberme");

		var curPartida:FLSqlCursor = new FLSqlCursor("co_partidas");
		with (curPartida) {
				setModeAccess(curPartida.Insert);
				refreshBuffer();
				setValueBuffer("idsubcuenta", ctaVentas.idsubcuenta);
				setValueBuffer("codsubcuenta", ctaVentas.codsubcuenta);
				setValueBuffer("idasiento", idAsiento);
				setValueBuffer("debe", 0);
				setValueBuffer("haber", haber);
				setValueBuffer("coddivisa", curFactura.valueBuffer("coddivisa"));
				setValueBuffer("tasaconv", curFactura.valueBuffer("tasaconv"));
				setValueBuffer("debeME", 0);
				setValueBuffer("haberME", haberME);
		}
		
		this.iface.datosPartidaFactura(curPartida, curFactura, "cliente")
		
		if (!curPartida.commitBuffer())
				return false;
		return true;
}

/** \D Genera la parte del asiento de factura correspondiente a la subcuenta de IVA y de recargo de equivalencia, si la factura lo tiene
@param	curFactura: Cursor de la factura
@param	idAsiento: Id del asiento asociado
@param	valoresDefecto: Array con los valores por defecto de ejercicio y divisa
@param	ctaCliente: Array con los datos de la contrapartida
@return	VERDADERO si no hay error, FALSO en otro caso
\end */
function oficial_generarPartidasIVACli(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array, ctaCliente:Array):Boolean
{
	var util:FLUtil = new FLUtil();
	var haber:Number = 0;
	var haberME:Number = 0;
	var baseImponible:Number = 0;
	
	var monedaSistema:Boolean = (valoresDefecto.coddivisa == curFactura.valueBuffer("coddivisa"));
	var qryIva:FLSqlQuery = new FLSqlQuery();
	qryIva.setTablesList("lineasivafactcli");
	qryIva.setSelect("neto, iva, totaliva, recargo, totalrecargo, codimpuesto");
	qryIva.setFrom("lineasivafactcli");
	qryIva.setWhere("idfactura = " + curFactura.valueBuffer("idfactura"));
	try { qryIva.setForwardOnly( true ); } catch (e) {}
	if (!qryIva.exec())
		return false;

	while (qryIva.next()) {
		if (monedaSistema) {
			haber = qryIva.value(2);
			haberME = 0;
			baseImponible = qryIva.value(0);
		} else {
			haber = parseFloat(qryIva.value(2)) * parseFloat(curFactura.valueBuffer("tasaconv"));
			haberME = qryIva.value(2);
			baseImponible = parseFloat(qryIva.value(0))  * parseFloat(curFactura.valueBuffer("tasaconv"));
		}
		haber = util.roundFieldValue(haber, "co_partidas", "haber");
		haberME = util.roundFieldValue(haberME, "co_partidas", "haberme");
		baseImponible = util.roundFieldValue(baseImponible, "co_partidas", "baseimponible");

		var ctaIvaRep:Array = this.iface.datosCtaIVA("IVAREP", valoresDefecto.codejercicio, qryIva.value(5));
		if (ctaIvaRep.error != 0)
			return false;
		var curPartida:FLSqlCursor = new FLSqlCursor("co_partidas");
		with (curPartida) {
			setModeAccess(curPartida.Insert);
			refreshBuffer();
			setValueBuffer("idsubcuenta", ctaIvaRep.idsubcuenta);
			setValueBuffer("codsubcuenta", ctaIvaRep.codsubcuenta);
			setValueBuffer("idasiento", idAsiento);
			setValueBuffer("debe", 0);
			setValueBuffer("haber", haber);
			setValueBuffer("baseimponible", baseImponible);
			setValueBuffer("iva", qryIva.value(1));
			setValueBuffer("recargo", qryIva.value(3));
			setValueBuffer("coddivisa", curFactura.valueBuffer("coddivisa"));
			setValueBuffer("tasaconv", curFactura.valueBuffer("tasaconv"));
			setValueBuffer("idcontrapartida", ctaCliente.idsubcuenta);
			setValueBuffer("codcontrapartida", ctaCliente.codsubcuenta);
			setValueBuffer("debeME", 0);
			setValueBuffer("haberME", haberME);
			setValueBuffer("codserie", curFactura.valueBuffer("codserie"));
			setValueBuffer("cifnif", curFactura.valueBuffer("cifnif"));
		}
		
		this.iface.datosPartidaFactura(curPartida, curFactura, "cliente")
		
		if (!curPartida.commitBuffer())
			return false;

		if (monedaSistema) {
			haber = qryIva.value(4);
			haberME = 0;
		} else {
			haber = parseFloat(qryIva.value(4)) * parseFloat(curFactura.valueBuffer("tasaconv"));
			haberME = qryIva.value(4);
		}
		haber = util.roundFieldValue(haber, "co_partidas", "haber");
		haberME = util.roundFieldValue(haberME, "co_partidas", "haberme");

		if (parseFloat(haber) != 0) {
			var ctaRecargo = this.iface.datosCtaIVA("IVAACR", valoresDefecto.codejercicio, qryIva.value(5));
			if (ctaRecargo.error != 0)
				return false;
			var curPartida:FLSqlCursor = new FLSqlCursor("co_partidas");
			with (curPartida) {
				setModeAccess(curPartida.Insert);
				refreshBuffer();
				setValueBuffer("idsubcuenta", ctaRecargo.idsubcuenta);
				setValueBuffer("codsubcuenta", ctaRecargo.codsubcuenta);
				setValueBuffer("idasiento", idAsiento);
				setValueBuffer("debe", 0);
				setValueBuffer("haber", haber);
				setValueBuffer("baseimponible", baseImponible);
				setValueBuffer("iva", qryIva.value(1));
				setValueBuffer("recargo", qryIva.value(3));
				setValueBuffer("coddivisa", curFactura.valueBuffer("coddivisa"));
				setValueBuffer("tasaconv", curFactura.valueBuffer("tasaconv"));
				setValueBuffer("idcontrapartida", ctaCliente.idsubcuenta);
				setValueBuffer("codcontrapartida", ctaCliente.codsubcuenta);
				setValueBuffer("debeME", 0);
				setValueBuffer("haberME", haberME);
				setValueBuffer("codserie", curFactura.valueBuffer("codserie"));
				setValueBuffer("cifnif", curFactura.valueBuffer("cifnif"));
			}
			
			this.iface.datosPartidaFactura(curPartida, curFactura, "cliente")
			
			if (!curPartida.commitBuffer())
				return false;
		}
	}
	return true;
}

/** \D Genera la parte del asiento de factura correspondiente a la subcuenta de IRPF, si la factura lo tiene
@param	curFactura: Cursor de la factura
@param	idAsiento: Id del asiento asociado
@param	valoresDefecto: Array con los valores por defecto de ejercicio y divisa
@return	VERDADERO si no hay error, FALSO en otro caso
\end */
function oficial_generarPartidasIRPF(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array):Boolean
{
		var util:FLUtil = new FLUtil();
		var irpf:Number = parseFloat(curFactura.valueBuffer("totalirpf"));
		if (irpf == 0)
				return true;
		var debe:Number = 0;
		var debeME:Number = 0;
		var ctaIrpf:Array = this.iface.datosCtaEspecial("IRPF", valoresDefecto.codejercicio);
		if (ctaIrpf.error != 0) {
			MessageBox.warning(util.translate("scripts", "No tiene ninguna cuenta contable marcada como cuenta especial\nIRPF (IRPF para clientes).\nDebe asociar la cuenta a la cuenta especial en el módulo Principal del área Financiera"), MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton);
			return false;
		}

		var monedaSistema:Boolean = (valoresDefecto.coddivisa == curFactura.valueBuffer("coddivisa"));
		if (monedaSistema) {
				debe = irpf;
				debeME = 0;
		} else {
				debe = irpf * parseFloat(curFactura.valueBuffer("tasaconv"));
				debeME = irpf;
		}
		debe = util.roundFieldValue(debe, "co_partidas", "debe");
		debeME = util.roundFieldValue(debeME, "co_partidas", "debeme");

		var curPartida:FLSqlCursor = new FLSqlCursor("co_partidas");
		with (curPartida) {
				setModeAccess(curPartida.Insert);
				refreshBuffer();
				setValueBuffer("idsubcuenta", ctaIrpf.idsubcuenta);
				setValueBuffer("codsubcuenta", ctaIrpf.codsubcuenta);
				setValueBuffer("idasiento", idAsiento);
				setValueBuffer("debe", debe);
				setValueBuffer("haber", 0);
				setValueBuffer("coddivisa", curFactura.valueBuffer("coddivisa"));
				setValueBuffer("tasaconv", curFactura.valueBuffer("tasaconv"));
				setValueBuffer("debeME", debeME);
				setValueBuffer("haberME", 0);
		}
		
		this.iface.datosPartidaFactura(curPartida, curFactura, "cliente")
		
		if (!curPartida.commitBuffer())
				return false;

		return true;
}

/** \D Genera la parte del asiento de factura correspondiente a la subcuenta de recargo financiero para clientes, si la factura lo tiene
@param	curFactura: Cursor de la factura
@param	idAsiento: Id del asiento asociado
@param	valoresDefecto: Array con los valores por defecto de ejercicio y divisa
@return	VERDADERO si no hay error, FALSO en otro caso
\end */
function oficial_generarPartidasRecFinCli(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array):Boolean
{
	var util:FLUtil = new FLUtil();
	var recFinanciero:Number = parseFloat(curFactura.valueBuffer("recfinanciero") * curFactura.valueBuffer("neto") / 100);
	if (!recFinanciero)
		return true;
	var haber:Number = 0;
	var haberME:Number = 0;

	var ctaRecfin:Array = [];
	ctaRecfin = this.iface.datosCtaEspecial("INGRF", valoresDefecto.codejercicio);
	if (ctaRecfin.error != 0) {
		MessageBox.warning(util.translate("scripts", "No tiene ninguna cuenta contable marcada como cuenta especial\nINGRF (recargo financiero en ingresos) \nDebe asociar una cuenta contable a esta cuenta especial en el módulo Principal del área Financiera"), MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton);
		return false;
	}

	var monedaSistema:Boolean = (valoresDefecto.coddivisa == curFactura.valueBuffer("coddivisa"));
	if (monedaSistema) {
		haber = recFinanciero;
		haberME = 0;
	} else {
		haber = recFinanciero * parseFloat(curFactura.valueBuffer("tasaconv"));
		haberME = recFinanciero;
	}
	haber = util.roundFieldValue(haber, "co_partidas", "haber");
	haberME = util.roundFieldValue(haberME, "co_partidas", "haberme");

	var curPartida:FLSqlCursor = new FLSqlCursor("co_partidas");
	with (curPartida) {
		setModeAccess(curPartida.Insert);
		refreshBuffer();
		setValueBuffer("idsubcuenta", ctaRecfin.idsubcuenta);
		setValueBuffer("codsubcuenta", ctaRecfin.codsubcuenta);
		setValueBuffer("idasiento", idAsiento);
		setValueBuffer("haber", haber);
		setValueBuffer("debe", 0);
		setValueBuffer("coddivisa", curFactura.valueBuffer("coddivisa"));
		setValueBuffer("tasaconv", curFactura.valueBuffer("tasaconv"));
		setValueBuffer("haberME", haberME);
		setValueBuffer("debeME", 0);
	}
	
	this.iface.datosPartidaFactura(curPartida, curFactura, "cliente")
	
	if (!curPartida.commitBuffer())
			return false;

	return true;
}

/** \D Genera la parte del asiento de factura correspondiente a la subcuenta de IRPF para proveedores, si la factura lo tiene
@param	curFactura: Cursor de la factura
@param	idAsiento: Id del asiento asociado
@param	valoresDefecto: Array con los valores por defecto de ejercicio y divisa
@return	VERDADERO si no hay error, FALSO en otro caso
\end */
function oficial_generarPartidasIRPFProv(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array):Boolean
{
	var util:FLUtil = new FLUtil();
	var irpf:Number = parseFloat(curFactura.valueBuffer("totalirpf"));
	if (irpf == 0)
			return true;
	var haber:Number = 0;
	var haberME:Number = 0;

	var ctaIrpf:Array = [];
	ctaIrpf.codsubcuenta = util.sqlSelect("lineasfacturasprov lf INNER JOIN articulos a ON lf.referencia = a.referencia", "a.codsubcuentairpfcom", "lf.idfactura = " + curFactura.valueBuffer("idfactura") + " AND a.codsubcuentairpfcom IS NOT NULL", "lineasfacturasprov,articulos");
	if (ctaIrpf.codsubcuenta) {
		var hayDistintasSubcuentas:String = util.sqlSelect("lineasfacturasprov lf INNER JOIN articulos a ON lf.referencia = a.referencia", "a.referencia", "lf.idfactura = " + curFactura.valueBuffer("idfactura") + " AND (a.codsubcuentairpfcom <> '" + ctaIrpf.codsubcuenta + "' OR a.codsubcuentairpfcom  IS NULL)", "lineasfacturasprov,articulos");
		if (hayDistintasSubcuentas) {
			MessageBox.warning(util.translate("scripts", "No es posible generar el asiento contable de una factura que tiene artículos asignados a distintas subcuentas de IRPF.\nDebe corregir la asociación de las subcuentas de IRPF a los artículos o bien crear distintas facturas para cada subcuenta."), MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton);
			return false;
		}
		ctaIrpf.idsubcuenta = util.sqlSelect("co_subcuentas", "idsubcuenta", "codsubcuenta = '" + ctaIrpf.codsubcuenta + "' AND codejercicio = '" + valoresDefecto.codejercicio + "'");
		if (!ctaIrpf.idsubcuenta) {
			MessageBox.warning(util.translate("scripts", "No existe la subcuenta de IRPF %1 para el ejercicio %2.\nAntes de generar el asiento debe crear esta subcuenta.").arg(ctaIrpf.codsubcuenta).arg(valoresDefecto.codejercicio), MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton);
			return false;
		}
	} else {
		ctaIrpf = this.iface.datosCtaEspecial("IRPFPR", valoresDefecto.codejercicio);
		if (ctaIrpf.error != 0) {
			MessageBox.warning(util.translate("scripts", "No tiene ninguna cuenta contable marcada como cuenta especial\nIRPFPR (IRPF para proveedores / acreedores).\nDebe asociar la cuenta a la cuenta especial en el módulo Principal del área Financiera"), MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton);
			return false;
		}
	}

	var monedaSistema:Boolean = (valoresDefecto.coddivisa == curFactura.valueBuffer("coddivisa"));
	if (monedaSistema) {
		haber = irpf;
		haberME = 0;
	} else {
		haber = irpf * parseFloat(curFactura.valueBuffer("tasaconv"));
		haberME = irpf;
	}
	haber = util.roundFieldValue(haber, "co_partidas", "haber");
	haberME = util.roundFieldValue(haberME, "co_partidas", "haberme");

	var curPartida:FLSqlCursor = new FLSqlCursor("co_partidas");
	with (curPartida) {
		setModeAccess(curPartida.Insert);
		refreshBuffer();
		setValueBuffer("idsubcuenta", ctaIrpf.idsubcuenta);
		setValueBuffer("codsubcuenta", ctaIrpf.codsubcuenta);
		setValueBuffer("idasiento", idAsiento);
		setValueBuffer("debe", 0);
		setValueBuffer("haber", haber);
		setValueBuffer("coddivisa", curFactura.valueBuffer("coddivisa"));
		setValueBuffer("tasaconv", curFactura.valueBuffer("tasaconv"));
		setValueBuffer("debeME", 0);
		setValueBuffer("haberME", haberME);
	}
	
	this.iface.datosPartidaFactura(curPartida, curFactura, "proveedor")
	
	if (!curPartida.commitBuffer())
			return false;

	return true;
}


/** \D Genera la parte del asiento de factura correspondiente a la subcuenta de clientes
@param	curFactura: Cursor de la factura
@param	idAsiento: Id del asiento asociado
@param	valoresDefecto: Array con los valores por defecto de ejercicio y divisa
@param	ctaCliente: Datos de la subcuenta del cliente asociado a la factura
@return	VERDADERO si no hay error, FALSO en otro caso
\end */
function oficial_generarPartidasCliente(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array, ctaCliente:Array):Boolean
{
		var util:FLUtil = new FLUtil();
		var debe:Number = 0;
		var debeME:Number = 0;
		var monedaSistema:Boolean = (valoresDefecto.coddivisa == curFactura.valueBuffer("coddivisa"));
		if (monedaSistema) {
				debe = curFactura.valueBuffer("total");
				debeME = 0;
		} else {
				debe = parseFloat(curFactura.valueBuffer("total")) * parseFloat(curFactura.valueBuffer("tasaconv"));
				debeME = curFactura.valueBuffer("total");
		}
		debe = util.roundFieldValue(debe, "co_partidas", "debe");
		debeME = util.roundFieldValue(debeME, "co_partidas", "debeme");
		
		var curPartida:FLSqlCursor = new FLSqlCursor("co_partidas");
		with (curPartida) {
				setModeAccess(curPartida.Insert);
				refreshBuffer();
				setValueBuffer("idsubcuenta", ctaCliente.idsubcuenta);
				setValueBuffer("codsubcuenta", ctaCliente.codsubcuenta);
				setValueBuffer("idasiento", idAsiento);
				setValueBuffer("debe", debe);
				setValueBuffer("haber", 0);
				setValueBuffer("coddivisa", curFactura.valueBuffer("coddivisa"));
				setValueBuffer("tasaconv", curFactura.valueBuffer("tasaconv"));
				setValueBuffer("debeME", debeME);
				setValueBuffer("haberME", 0);
		}
		
		this.iface.datosPartidaFactura(curPartida, curFactura, "cliente")
		
		if (!curPartida.commitBuffer())
				return false;

		return true;
}

/** \D Genera o regenera el registro en la tabla de asientos correspondiente a la factura. Si el asiento ya estaba creado borra sus partidas asociadas.
@param	curFactura: Cursor posicionado en el registro de factura
@param	valoresDefecto: Array con los valores por defecto de ejercicio y divisa
@return	array con los siguientes datos:
asiento.idasiento: Id del asiento
asiento.numero: numero del asiento
asiento.fecha: fecha del asiento
asiento.error: indicador booleano de que ha habido un error en la función
\end */
function oficial_regenerarAsiento(curFactura:FLSqlCursor, valoresDefecto:Array):Array
{
	var util:FLUtil = new FLUtil;
	var asiento:Array = [];
	var idAsiento:Number = curFactura.valueBuffer("idasiento");
	if (curFactura.isNull("idasiento")) {
		var curAsiento:FLSqlCursor = new FLSqlCursor("co_asientos");
		//var numAsiento:Number = util.sqlSelect("co_asientos", "MAX(numero)",  "codejercicio = '" + valoresDefecto.codejercicio + "'");
		//numAsiento++;
		with (curAsiento) {
			setModeAccess(curAsiento.Insert);
			refreshBuffer();
			setValueBuffer("numero", 0);
			setValueBuffer("fecha", curFactura.valueBuffer("fecha"));
			setValueBuffer("codejercicio", valoresDefecto.codejercicio);
		}
		if (!curAsiento.commitBuffer()) {
			asiento.error = true;
			return asiento;
		}
		asiento.idasiento = curAsiento.valueBuffer("idasiento");
		asiento.numero = curAsiento.valueBuffer("numero");
		asiento.fecha = curAsiento.valueBuffer("fecha");
		curAsiento.select("idasiento = " + asiento.idasiento);
		curAsiento.first();
		curAsiento.setUnLock("editable", false);
	} else {
		if (!this.iface.asientoBorrable(idAsiento)) {
			asiento.error = true;
			return asiento;
		}

		if (curFactura.valueBuffer("fecha") != curFactura.valueBufferCopy("fecha")) {
			var curAsiento:FLSqlCursor = new FLSqlCursor("co_asientos");
			curAsiento.select("idasiento = " + idAsiento);
			if (!curAsiento.first()) {
				asiento.error = true;
				return asiento;
			}
			curAsiento.setUnLock("editable", true);

			curAsiento.select("idasiento = " + idAsiento);
			if (!curAsiento.first()) {
				asiento.error = true;
				return asiento;
			}
			curAsiento.setModeAccess(curAsiento.Edit);
			curAsiento.refreshBuffer();
			curAsiento.setValueBuffer("fecha", curFactura.valueBuffer("fecha"));

			if (!curAsiento.commitBuffer()) {
				asiento.error = true;
				return asiento;
			}
			curAsiento.select("idasiento = " + idAsiento);
			if (!curAsiento.first()) {
				asiento.error = true;
				return asiento;
			}
			curAsiento.setUnLock("editable", false);
		}

		asiento = flfactppal.iface.pub_ejecutarQry("co_asientos", "idasiento,numero,fecha,codejercicio", "idasiento = '" + idAsiento + "'");
		if (asiento.codejercicio != valoresDefecto.codejercicio) {
			MessageBox.warning(util.translate("scripts", "Está intentando regenerar un asiento del ejercicio %1 en el ejercicio %2.\nVerifique que su ejercicio actual es correcto. Si lo es y está actualizando un pago, bórrelo y vuélvalo a crear.").arg(asiento.codejercicio).arg(valoresDefecto.codejercicio), MessageBox.Ok, MessageBox.NoButton);
			asiento.error = true;
			return asiento;
		}
		var curPartidas = new FLSqlCursor("co_partidas");
		curPartidas.select("idasiento = " + idAsiento);
		while (curPartidas.next()) {
			curPartidas.setModeAccess(curPartidas.Del);
			curPartidas.refreshBuffer();
			if (!curPartidas.commitBuffer()) {
				asiento.error = true;
				return asiento;
			}
		}
	}

	asiento.error = false;
	return asiento;
}

function oficial_eliminarAsiento(idAsiento:String):Boolean
{
	var util:FLUtil = new FLUtil;
	if (!idAsiento || idAsiento == "")
		return true;

	if (!this.iface.asientoBorrable(idAsiento))
		return false;

	var curAsiento:FLSqlCursor = new FLSqlCursor("co_asientos");
	curAsiento.select("idasiento = " + idAsiento);
	if (!curAsiento.first())
		return false;

	curAsiento.setUnLock("editable", true);
	if (!util.sqlDelete("co_asientos", "idasiento = " + idAsiento)) {
		curAsiento.setValueBuffer("idasiento", idAsiento);
		return false;
	}

	return true;
}

/** \U Genera o regenera el asiento correspondiente a una factura de proveedor
@param	curFactura: Cursor con los datos de la factura
@return	VERDADERO si no hay error. FALSO en otro caso
\end */
/** \C El concepto de los asientos de factura de proveedor será 'Su factura ' + número de proveedor asociado a la factura. Si el número de proveedor no se especifica, el concepto será 'Su factura ' + código de factura.
\end */
function oficial_generarAsientoFacturaProv(curFactura:FLSqlCursor):Boolean
{
	if (curFactura.modeAccess() != curFactura.Insert && curFactura.modeAccess() != curFactura.Edit)
		return true;

	var util:FLUtil = new FLUtil;
	if (curFactura.valueBuffer("nogenerarasiento")) {
		curFactura.setNull("idasiento");
		return true;
	}

	if (!this.iface.comprobarRegularizacion(curFactura))
		return false;

	var util:FLUtil = new FLUtil();
	var datosAsiento:Array = [];
	var valoresDefecto:Array;
	valoresDefecto["codejercicio"] = curFactura.valueBuffer("codejercicio");
	valoresDefecto["coddivisa"] = flfactppal.iface.pub_valorDefectoEmpresa("coddivisa");

	datosAsiento = this.iface.regenerarAsiento(curFactura, valoresDefecto);
	if (datosAsiento.error == true)
		return false;

	var numProveedor:String = curFactura.valueBuffer("numproveedor");
	var concepto:String;
	if (!numProveedor || numProveedor == "")
		concepto = util.translate("scripts", "Su factura ") + curFactura.valueBuffer("codigo");
	else
		concepto = util.translate("scripts", "Su factura ") + numProveedor;
	concepto += " - " + curFactura.valueBuffer("nombre");

	var ctaProveedor:Array = this.iface.datosCtaProveedor(curFactura, valoresDefecto);
	if (ctaProveedor.error != 0)
		return false;

	// Las partidas generadas dependen del régimen de IVA del proveedor
	var regimenIVA:String = util.sqlSelect("proveedores", "regimeniva", "codproveedor = '" + curFactura.valueBuffer("codproveedor") + "'");
	
	switch(regimenIVA) {
		case "UE":
			if (!this.iface.generarPartidasProveedor(curFactura, datosAsiento.idasiento, valoresDefecto, ctaProveedor, concepto, true))
				return false;
				
			if (!this.iface.generarPartidasIRPFProv(curFactura, datosAsiento.idasiento, valoresDefecto))
				return false;
		
			if (!this.iface.generarPartidasRecFinProv(curFactura, datosAsiento.idasiento, valoresDefecto))
				return false;				
			
			if (!this.iface.generarPartidasIVAProv(curFactura, datosAsiento.idasiento, valoresDefecto, ctaProveedor, concepto))
				return false;
		
			if (!this.iface.generarPartidasCompra(curFactura, datosAsiento.idasiento, valoresDefecto, concepto))
				return false;
		break;
		
		case "Exento":
			if (!this.iface.generarPartidasProveedor(curFactura, datosAsiento.idasiento, valoresDefecto, ctaProveedor, concepto, true))
				return false;
				
			if (!this.iface.generarPartidasRecFinProv(curFactura, datosAsiento.idasiento, valoresDefecto))
				return false;				
			
			if (!this.iface.generarPartidasIRPFProv(curFactura, datosAsiento.idasiento, valoresDefecto))
				return false;
		
			if (!this.iface.generarPartidasCompra(curFactura, datosAsiento.idasiento, valoresDefecto, concepto))
				return false;
		break;
		
		default:
			if (!this.iface.generarPartidasProveedor(curFactura, datosAsiento.idasiento, valoresDefecto, ctaProveedor, concepto))
				return false;
				
			if (!this.iface.generarPartidasIRPFProv(curFactura, datosAsiento.idasiento, valoresDefecto))
				return false;
		
			if (!this.iface.generarPartidasRecFinProv(curFactura, datosAsiento.idasiento, valoresDefecto))
				return false;				
			
			if (!this.iface.generarPartidasIVAProv(curFactura, datosAsiento.idasiento, valoresDefecto, ctaProveedor, concepto))
				return false;
		
			if (!this.iface.generarPartidasCompra(curFactura, datosAsiento.idasiento, valoresDefecto, concepto))
				return false;
	}
		
	curFactura.setValueBuffer("idasiento", datosAsiento.idasiento);
		
	if (curFactura.valueBuffer("deabono") == true)
		if (!this.iface.asientoFacturaAbonoProv(curFactura, valoresDefecto))
			return false;

	if (!flcontppal.iface.pub_comprobarAsiento(datosAsiento.idasiento))
		return false;

	return true;
}

/** \D Genera la parte del asiento de factura de proveedor correspondiente a la subcuenta de compras
@param	curFactura: Cursor de la factura
@param	idAsiento: Id del asiento asociado
@param	valoresDefecto: Array con los valores por defecto de ejercicio y divisa
@param	concepto: Concepto de la partida
@return	VERDADERO si no hay error, FALSO en otro caso
\end */
function oficial_generarPartidasCompra(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array, concepto:String):Boolean
{
		var ctaCompras:Array = [];
		var util:FLUtil = new FLUtil();
		var monedaSistema:Boolean = (valoresDefecto.coddivisa == curFactura.valueBuffer("coddivisa"));
		var debe:Number = 0;
		var debeME:Number = 0;
		var idUltimaPartida:Number = 0;

		/** \C En el asiento correspondiente a las facturas de proveedor, se generarán tantas partidas de compra como subcuentas distintas existan en las líneas de factura
		\end */
		var qrySubcuentas:FLSqlQuery = new FLSqlQuery();
		with (qrySubcuentas) {
				setTablesList("lineasfacturasprov");
				setSelect("codsubcuenta, SUM(pvptotal)");
				setFrom("lineasfacturasprov");
				setWhere("idfactura = " + curFactura.valueBuffer("idfactura") +
						" GROUP BY codsubcuenta");
		}
		try { qrySubcuentas.setForwardOnly( true ); } catch (e) {}
		
		if (!qrySubcuentas.exec())
				return false;
		while (qrySubcuentas.next()) {
				if (qrySubcuentas.value(0) == "" || !qrySubcuentas.value(0)) {
						ctaCompras = this.iface.datosCtaEspecial("COMPRA", valoresDefecto.codejercicio);
						if (ctaCompras.error != 0)
								return false;
				} else {
						ctaCompras.codsubcuenta = qrySubcuentas.value(0);
						ctaCompras.idsubcuenta = util.sqlSelect("co_subcuentas", "idsubcuenta",
								"codsubcuenta = '" + qrySubcuentas.value(0) +
								"' AND codejercicio = '" + valoresDefecto.codejercicio + "'");
						if (!ctaCompras.idsubcuenta) {
								MessageBox.warning(util.translate("scripts", "No existe la subcuenta ")  + ctaCompras.codsubcuenta +
										util.translate("scripts", " correspondiente al ejercicio ") + valoresDefecto.codejercicio +
										util.translate("scripts", ".\nPara poder crear la factura debe crear antes esta subcuenta"),
										MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton);
								return false;
						}
				}

				if (monedaSistema) {
						debe = parseFloat(qrySubcuentas.value(1));
						debeME = 0;
				} else {
						debe = parseFloat(qrySubcuentas.value(1)) * parseFloat(curFactura.valueBuffer("tasaconv"));
						debeME = parseFloat(qrySubcuentas.value(1));
				}
				debe = util.roundFieldValue(debe, "co_partidas", "debe");
				debeME = util.roundFieldValue(debeME, "co_partidas", "debeme");
				
				var curPartida:FLSqlCursor = new FLSqlCursor("co_partidas");
				with (curPartida) {
						setModeAccess(curPartida.Insert);
						refreshBuffer();
						setValueBuffer("idsubcuenta", ctaCompras.idsubcuenta);
						setValueBuffer("codsubcuenta", ctaCompras.codsubcuenta);
						setValueBuffer("idasiento", idAsiento);
						setValueBuffer("debe", debe);
						setValueBuffer("haber", 0);
						setValueBuffer("coddivisa", curFactura.valueBuffer("coddivisa"));
						setValueBuffer("tasaconv", curFactura.valueBuffer("tasaconv"));
						setValueBuffer("debeME", debeME);
						setValueBuffer("haberME", 0);
				}
				
				this.iface.datosPartidaFactura(curPartida, curFactura, "proveedor", concepto);
				
				if (!curPartida.commitBuffer())
						return false;
				idUltimaPartida = curPartida.valueBuffer("idpartida");
		}

		/** \C En los asientos de factura de proveedor, y en el caso de que se use moneda extranjera, la última partida de compras tiene un saldo tal que haga que el asiento cuadre perfectamente. Esto evita errores de redondeo de conversión de moneda entre las partidas del asiento.
		\end */
		if (!monedaSistema) {
			debe = util.sqlSelect("co_partidas", "SUM(haber - debe)", "idasiento = " + idAsiento + " AND idpartida <> " + idUltimaPartida);
			if (debe && !isNaN(debe) && debe != 0) {
				debe = util.roundFieldValue(debe, "co_partidas", "debe");
				if (!util.sqlUpdate("co_partidas", "debe", debe, "idpartida = " + idUltimaPartida))
						return false;
			}
		}

		return true;
}

/** \D Genera la parte del asiento de factura de proveedor correspondiente a la subcuenta de IVA y de recargo de equivalencia, si la factura lo tiene
@param	curFactura: Cursor de la factura
@param	idAsiento: Id del asiento asociado
@param	valoresDefecto: Array con los valores por defecto de ejercicio y divisa
@param	ctaProveedor: Array con los datos de la contrapartida
@param	concepto: Concepto de la partida
@return	VERDADERO si no hay error, FALSO en otro caso
\end */
function oficial_generarPartidasIVAProv(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array, ctaProveedor:Array, concepto:String):Boolean
{
	var util:FLUtil = new FLUtil();
	var haber:Number = 0;
	var haberME:Number = 0;
	var baseImponible:Number = 0;
	var monedaSistema:Boolean = (valoresDefecto.coddivisa == curFactura.valueBuffer("coddivisa"));
	
	var regimenIVA:String = util.sqlSelect("proveedores","regimeniva","codproveedor = '" + curFactura.valueBuffer("codproveedor") + "'");
	var codCuentaEspIVA:String;
	
	var qryIva:FLSqlQuery = new FLSqlQuery();
	qryIva.setTablesList("lineasivafactprov");
	
	if (regimenIVA == "UE")
		qryIva.setSelect("neto, iva, neto*iva/100, recargo, neto*recargo/100, codimpuesto");
	else
		qryIva.setSelect("neto, iva, totaliva, recargo, totalrecargo, codimpuesto");	
	
	qryIva.setFrom("lineasivafactprov");
	qryIva.setWhere("idfactura = " + curFactura.valueBuffer("idfactura"));
	try { qryIva.setForwardOnly( true ); } catch (e) {}
	if (!qryIva.exec())
		return false;

		
	while (qryIva.next()) {
		if (monedaSistema) {
			debe = qryIva.value(2);
			debeME = 0;
			baseImponible = qryIva.value(0);
		} else {
			debe = parseFloat(qryIva.value(2)) * parseFloat(curFactura.valueBuffer("tasaconv"));
			debeME = qryIva.value(2);
			baseImponible = parseFloat(qryIva.value(0)) * parseFloat(curFactura.valueBuffer("tasaconv"));
		}
		debe = util.roundFieldValue(debe, "co_partidas", "debe");
		debeME = util.roundFieldValue(debeME, "co_partidas", "debeme");
		baseImponible = util.roundFieldValue(baseImponible, "co_partidas", "baseimponible");
		
		switch(regimenIVA) {
			case "UE":
				codCuentaEspIVA = "IVASUE";
				break;
			case "General":
			case "Exento":
			case "Exportaciones":
				codCuentaEspIVA = "IVASOP";
				break;
			default:
				codCuentaEspIVA = "IVASOP";
		}
		
		var ctaIvaSop:Array = this.iface.datosCtaIVA(codCuentaEspIVA, valoresDefecto.codejercicio, qryIva.value(5));
		if (ctaIvaSop.error != 0) {
			MessageBox.warning(util.translate("scripts", "Esta factura pertenece al régimen IVA tipo %1.\nNo existe ninguna cuenta contable marcada como tipo especial %1\n\nDebe asociar una cuenta contable a dicho tipo especial en el módulo Principal del área Financiera").arg(regimenIVA).arg(codCuentaEspIVA), MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton);
			return false;
		}			
		var curPartida:FLSqlCursor = new FLSqlCursor("co_partidas");
		with (curPartida) {
			setModeAccess(curPartida.Insert);
			refreshBuffer();
			setValueBuffer("idsubcuenta", ctaIvaSop.idsubcuenta);
			setValueBuffer("codsubcuenta", ctaIvaSop.codsubcuenta);
			setValueBuffer("idasiento", idAsiento);
			setValueBuffer("debe", debe);
			setValueBuffer("haber", 0);
			setValueBuffer("baseimponible", baseImponible);
			setValueBuffer("iva", qryIva.value(1));
			setValueBuffer("recargo", qryIva.value(3));
			setValueBuffer("coddivisa", curFactura.valueBuffer("coddivisa"));
			setValueBuffer("tasaconv", curFactura.valueBuffer("tasaconv"));
			setValueBuffer("idcontrapartida", ctaProveedor.idsubcuenta);
			setValueBuffer("codcontrapartida", ctaProveedor.codsubcuenta);
			setValueBuffer("debeME", debeME);
			setValueBuffer("haberME", 0);
			setValueBuffer("codserie", curFactura.valueBuffer("codserie"));
			setValueBuffer("cifnif", curFactura.valueBuffer("cifnif"));
		}
		
		this.iface.datosPartidaFactura(curPartida, curFactura, "proveedor")
		
		if (!curPartida.commitBuffer())
			return false;

		
		// Otra partida de haber de IVA sobre una cuenta 477 para compensar en UE
		if (regimenIVA == "UE") {
			
			haber = debe;
			haberME = debeME;
			codCuentaEspIVA = "IVARUE";
			var ctaIvaSop:Array = this.iface.datosCtaIVA(codCuentaEspIVA, valoresDefecto.codejercicio, qryIva.value(5));
			if (ctaIvaSop.error != 0) {
				MessageBox.warning(util.translate("scripts", "Esta factura pertenece al régimen IVA tipo %1.\nNo existe ninguna cuenta contable marcada como tipo especial %1\n\nDebe asociar una cuenta contable a dicho tipo especial en el módulo Principal del área Financiera").arg(regimenIVA).arg(codCuentaEspIVA), MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton);
				return false;
			}			
			var curPartida:FLSqlCursor = new FLSqlCursor("co_partidas");
			with (curPartida) {
				setModeAccess(curPartida.Insert);
				refreshBuffer();
				setValueBuffer("idsubcuenta", ctaIvaSop.idsubcuenta);
				setValueBuffer("codsubcuenta", ctaIvaSop.codsubcuenta);
				setValueBuffer("idasiento", idAsiento);
				setValueBuffer("debe", 0);
				setValueBuffer("haber", haber);
				setValueBuffer("baseimponible", baseImponible);
				setValueBuffer("iva", qryIva.value(1));
				setValueBuffer("recargo", qryIva.value(3));
				setValueBuffer("coddivisa", curFactura.valueBuffer("coddivisa"));
				setValueBuffer("tasaconv", curFactura.valueBuffer("tasaconv"));
				setValueBuffer("idcontrapartida", ctaProveedor.idsubcuenta);
				setValueBuffer("codcontrapartida", ctaProveedor.codsubcuenta);
				setValueBuffer("debeME", 0);
				setValueBuffer("haberME", haberME);
				setValueBuffer("codserie", curFactura.valueBuffer("codserie"));
				setValueBuffer("cifnif", curFactura.valueBuffer("cifnif"));
			}
		
			this.iface.datosPartidaFactura(curPartida, curFactura, "proveedor", concepto)
			
			if (!curPartida.commitBuffer())
				return false;
		}
			
		if (monedaSistema) {
			debe = qryIva.value(4);
			debeME = 0;
		} else {
			debe = parseFloat(qryIva.value(4)) * parseFloat(curFactura.valueBuffer("tasaconv"));
			debeME = qryIva.value(4);
		}
		debe = util.roundFieldValue(debe, "co_partidas", "debe");
		debeME = util.roundFieldValue(debeME, "co_partidas", "debeme");

		if (parseFloat(debe) != 0) {
			var ctaRecargo:Array = this.iface.datosCtaIVA("IVADEU", valoresDefecto.codejercicio, qryIva.value(5));
			if (ctaRecargo.error != 0)
				return false;
			var curPartida:FLSqlCursor = new FLSqlCursor("co_partidas");
			with (curPartida) {
				setModeAccess(curPartida.Insert);
				refreshBuffer();
				setValueBuffer("idsubcuenta", ctaRecargo.idsubcuenta);
				setValueBuffer("codsubcuenta", ctaRecargo.codsubcuenta);
				setValueBuffer("idasiento", idAsiento);
				setValueBuffer("debe", debe);
				setValueBuffer("haber", 0);
				setValueBuffer("baseimponible", baseImponible);
				setValueBuffer("iva", qryIva.value(1));
				setValueBuffer("recargo", qryIva.value(3));
				setValueBuffer("coddivisa", curFactura.valueBuffer("coddivisa"));
				setValueBuffer("tasaconv", curFactura.valueBuffer("tasaconv"));
				setValueBuffer("idcontrapartida", ctaProveedor.idsubcuenta);
				setValueBuffer("codcontrapartida", ctaProveedor.codsubcuenta);
				setValueBuffer("debeME", debeME);
				setValueBuffer("haberME", 0);
				setValueBuffer("codserie", curFactura.valueBuffer("codserie"));
				setValueBuffer("cifnif", curFactura.valueBuffer("cifnif"));
			}
		
			this.iface.datosPartidaFactura(curPartida, curFactura, "proveedor", concepto)
			
			if (!curPartida.commitBuffer())
				return false;
		}
	}
	return true;
}

/** \D Genera la parte del asiento de factura correspondiente a la subcuenta de proveedor
@param	curFactura: Cursor de la factura
@param	idAsiento: Id del asiento asociado
@param	valoresDefecto: Array con los valores por defecto de ejercicio y divisa
@param	ctaCliente: Datos de la subcuenta del proveedor asociado a la factura
@param	concepto: Concepto a asociar a la factura
@return	VERDADERO si no hay error, FALSO en otro caso
\end */
function oficial_generarPartidasProveedor(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array, ctaProveedor:Array, concepto:String, sinIVA:Boolean):Boolean
{
		var util:FLUtil = new FLUtil;
		var haber:Number = 0;
		var haberME:Number = 0;
		var totalIVA:Number = 0;
		
		if (sinIVA)
			totalIVA = parseFloat(curFactura.valueBuffer("totaliva"));
		
		var monedaSistema:Boolean = (valoresDefecto.coddivisa == curFactura.valueBuffer("coddivisa"));
		if (monedaSistema) {
				haber = curFactura.valueBuffer("total");
				haber -= totalIVA;
				haberME = 0;
		} else {
				haber = (parseFloat(curFactura.valueBuffer("total")) - totalIVA) * parseFloat(curFactura.valueBuffer("tasaconv"));
				haberME = curFactura.valueBuffer("total");
		}
		haber = util.roundFieldValue(haber, "co_partidas", "haber");
		haberME = util.roundFieldValue(haberME, "co_partidas", "haberme");

		var curPartida:FLSqlCursor = new FLSqlCursor("co_partidas");
		with (curPartida) {
				setModeAccess(curPartida.Insert);
				refreshBuffer();
				setValueBuffer("idsubcuenta", ctaProveedor.idsubcuenta);
				setValueBuffer("codsubcuenta", ctaProveedor.codsubcuenta);
				setValueBuffer("idasiento", idAsiento);
				setValueBuffer("debe", 0);
				setValueBuffer("haber", haber);
				setValueBuffer("coddivisa", curFactura.valueBuffer("coddivisa"));
				setValueBuffer("tasaconv", curFactura.valueBuffer("tasaconv"));
				setValueBuffer("debeME", 0);
				setValueBuffer("haberME", haberME);
		}
		
		this.iface.datosPartidaFactura(curPartida, curFactura, "proveedor", concepto);
		
		if (!curPartida.commitBuffer())
				return false;
		return true;
}

/** \D Genera la parte del asiento de factura correspondiente a la subcuenta de recargo financiero para proveedores, si la factura lo tiene
@param	curFactura: Cursor de la factura
@param	idAsiento: Id del asiento asociado
@param	valoresDefecto: Array con los valores por defecto de ejercicio y divisa
@return	VERDADERO si no hay error, FALSO en otro caso
\end */
function oficial_generarPartidasRecFinProv(curFactura:FLSqlCursor, idAsiento:Number, valoresDefecto:Array):Boolean
{
	var util:FLUtil = new FLUtil();
	var recFinanciero:Number = parseFloat(curFactura.valueBuffer("recfinanciero") * curFactura.valueBuffer("neto") / 100);
	if (!recFinanciero)
		return true;
	var debe:Number = 0;
	var debeME:Number = 0;

	var ctaRecfin:Array = [];
	ctaRecfin = this.iface.datosCtaEspecial("GTORF", valoresDefecto.codejercicio);
	if (ctaRecfin.error != 0) {
		MessageBox.warning(util.translate("scripts", "No tiene ninguna cuenta contable marcada como cuenta especial\nGTORF (recargo financiero en gastos).\nDebe asociar una cuenta contable a esta cuenta especial en el módulo Principal del área Financiera"), MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton);
		return false;
	}

	var monedaSistema:Boolean = (valoresDefecto.coddivisa == curFactura.valueBuffer("coddivisa"));
	if (monedaSistema) {
		debe = recFinanciero;
		debeME = 0;
	} else {
		debe = recFinanciero * parseFloat(curFactura.valueBuffer("tasaconv"));
		debeME = recFinanciero;
	}
	debe = util.roundFieldValue(debe, "co_partidas", "debe");
	debeME = util.roundFieldValue(debeME, "co_partidas", "debeme");

	var curPartida:FLSqlCursor = new FLSqlCursor("co_partidas");
	with (curPartida) {
		setModeAccess(curPartida.Insert);
		refreshBuffer();
		setValueBuffer("idsubcuenta", ctaRecfin.idsubcuenta);
		setValueBuffer("codsubcuenta", ctaRecfin.codsubcuenta);
		setValueBuffer("idasiento", idAsiento);
		setValueBuffer("debe", debe);
		setValueBuffer("haber", 0);
		setValueBuffer("coddivisa", curFactura.valueBuffer("coddivisa"));
		setValueBuffer("tasaconv", curFactura.valueBuffer("tasaconv"));
		setValueBuffer("debeME", debeME);
		setValueBuffer("haberME", 0);
	}
		
	this.iface.datosPartidaFactura(curPartida, curFactura, "proveedor", concepto);
	
	if (!curPartida.commitBuffer())
			return false;

	return true;
}

/* \D Devuelve el código e id de la subcuenta especial correspondiente a un determinado ejercicio. Primero trata de obtener los datos a partir del campo cuenta de co_cuentasesp. Si este no existe o no produce resultados, busca los datos de la cuenta (co_cuentas) marcada con el tipo especial buscado.
@param ctaEsp: Tipo de cuenta especial
@codEjercicio: Código de ejercicio
@return Los datos componen un vector de tres valores:
error: 0.Sin error 1.Datos no encontrados 2.Error al ejecutar la query
idsubcuenta: Identificador de la subcuenta
codsubcuenta: Código de la subcuenta
\end */
function oficial_datosCtaEspecial(ctaEsp:String, codEjercicio:String):Array
{
	var datos:Array = [];
	var q:FLSqlQuery = new FLSqlQuery();
	
	with(q) {
		setTablesList("co_subcuentas,co_cuentasesp");
		setSelect("s.idsubcuenta, s.codsubcuenta");
		setFrom("co_cuentasesp ce INNER JOIN co_subcuentas s ON ce.codsubcuenta = s.codsubcuenta");
		setWhere("idcuentaesp = '" + ctaEsp + "' AND s.codejercicio = '" + codEjercicio + "'  ORDER BY s.codsubcuenta");
	}
	try { q.setForwardOnly( true ); } catch (e) {}
	if (!q.exec()) {
		datos["error"] = 2;
		return datos;
	}
	if (q.next()) {
		datos["error"] = 0;
		datos["idsubcuenta"] = q.value(0);
		datos["codsubcuenta"] = q.value(1);
		return datos;
	}
	
	with(q) {
		setTablesList("co_cuentas,co_subcuentas,co_cuentasesp");
		setSelect("s.idsubcuenta, s.codsubcuenta");
		setFrom("co_cuentasesp ce INNER JOIN co_cuentas c ON ce.codcuenta = c.codcuenta INNER JOIN co_subcuentas s ON c.idcuenta = s.idcuenta");
		setWhere("ce.idcuentaesp = '" + ctaEsp + "' AND c.codejercicio = '" + codEjercicio + "' ORDER BY s.codsubcuenta");
	}
	try { q.setForwardOnly( true ); } catch (e) {}
	if (!q.exec()) {
		datos["error"] = 2;
		return datos;
	}
	if (q.next()) {
		datos["error"] = 0;
		datos["idsubcuenta"] = q.value(0);
		datos["codsubcuenta"] = q.value(1);
		return datos;
	}

	with(q) {
		setTablesList("co_cuentas,co_subcuentas");
		setSelect("s.idsubcuenta, s.codsubcuenta");
		setFrom("co_cuentas c INNER JOIN co_subcuentas s ON c.idcuenta = s.idcuenta");
		setWhere("c.idcuentaesp = '" + ctaEsp + "' AND c.codejercicio = '" + codEjercicio + "' ORDER BY s.codsubcuenta");
	}
	try { q.setForwardOnly( true ); } catch (e) {}
	if (!q.exec()) {
		datos["error"] = 2;
		return datos;
	}
	if (!q.next()) {
		datos["error"] = 1;
		return datos;
	}

	datos["error"] = 0;
	datos["idsubcuenta"] = q.value(0);
	datos["codsubcuenta"] = q.value(1);
	return datos;
}

/* \D Devuelve el código e id de la subcuenta correspondiente a un impuesto y ejercicio determinados
@param	ctaEsp: Tipo de cuenta (IVA soportado, repercutido, Recargo de equivalencia)

@param	codEjercicio: Código de ejercicio
@param	codImpuesto: Código de impuesto
@return Los datos componen un vector de tres valores:
error: 0.Sin error 1.Datos no encontrados 2.Error al ejecutar la query
idsubcuenta: Identificador de la subcuenta
codsubcuenta: Código de la subcuenta
\end */
function oficial_datosCtaIVA(tipo:String, codEjercicio:String, codImpuesto:String):Array
{
		if (!codImpuesto || codImpuesto == "")
				return this.iface.datosCtaEspecial(tipo, codEjercicio);

		var util:FLUtil = new FLUtil();
		var datos:Array = [];
		var codSubcuenta:String;
		if (tipo == "IVAREP")
				codSubcuenta = util.sqlSelect("impuestos", "codsubcuentarep", "codimpuesto = '" + codImpuesto + "'");
		if (tipo == "IVASOP")
				codSubcuenta = util.sqlSelect("impuestos", "codsubcuentasop", "codimpuesto = '" + codImpuesto + "'");
		if (tipo == "IVAACR")
				codSubcuenta = util.sqlSelect("impuestos", "codsubcuentaacr", "codimpuesto = '" + codImpuesto + "'");
		if (tipo == "IVADEU")
				codSubcuenta = util.sqlSelect("impuestos", "codsubcuentadeu", "codimpuesto = '" + codImpuesto + "'");

		if (!codSubcuenta || codSubcuenta == "") {
				return this.iface.datosCtaEspecial(tipo, codEjercicio);
		}

		var q:FLSqlQuery = new FLSqlQuery();
		with(q) {
				setTablesList("co_subcuentas");
				setSelect("idsubcuenta, codsubcuenta");
				setFrom("co_subcuentas");
				setWhere("codsubcuenta = '" + codSubcuenta + "' AND codejercicio = '" + codEjercicio + "'");
		}
		try { q.setForwardOnly( true ); } catch (e) {}
		if (!q.exec()) {
				datos["error"] = 2;
				return datos;
		}
		if (!q.next()) {
				return this.iface.datosCtaEspecial(tipo, codEjercicio);
		}

		datos["error"] = 0;
		datos["idsubcuenta"] = q.value(0);
		datos["codsubcuenta"] = q.value(1);
		return datos;
}

/* \D Devuelve el código e id de la subcuenta de ventas correspondiente a un determinado ejercicio. La cuenta de ventas es la asignada a la serie de facturación. En caso de no estar establecida es la correspondiente a la subcuenta especial marcada como ventas
@param ctaEsp: Tipo de cuenta especial
@param codEjercicio: Código de ejercicio
@param codSerie: Código de serie de la factura
@return Los datos componen un vector de tres valores:
error: 0.Sin error 1.Datos no encontrados 2.Error al ejecutar la query
idsubcuenta: Identificador de la subcuenta
codsubcuenta: Código de la subcuenta
\end */
function oficial_datosCtaVentas(codEjercicio:String, codSerie:String):Array
{
		var util:FLUtil = new FLUtil();
		var datos:Array = [];

		var codCuenta:String = util.sqlSelect("series", "codcuenta", "codserie = '" + codSerie + "'");
		if (codCuenta.toString().isEmpty())
				return this.iface.datosCtaEspecial("VENTAS", codEjercicio);

		var q:FLSqlQuery = new FLSqlQuery();
		with(q) {
				setTablesList("co_cuentas,co_subcuentas");
				setSelect("idsubcuenta, codsubcuenta");
				setFrom("co_cuentas c INNER JOIN co_subcuentas s ON c.idcuenta = s.idcuenta");
				setWhere("c.codcuenta = '" + codCuenta + "' AND c.codejercicio = '" + codEjercicio + "' ORDER BY codsubcuenta");
		}
		try { q.setForwardOnly( true ); } catch (e) {}
		if (!q.exec()) {
				datos["error"] = 2;
				return datos;
		}
		if (!q.next()) {
				datos["error"] = 1;
				return datos;
		}

		datos["error"] = 0;
		datos["idsubcuenta"] = q.value(0);
		datos["codsubcuenta"] = q.value(1);
		return datos;
}

/* \D Devuelve el código e id de la subcuenta de cliente correspondiente a una  determinada factura
@param curFactura: Cursor posicionado en la factura
@param valoresDefecto: Array con los datos de ejercicio y divisa actuales
@return Los datos componen un vector de tres valores:
error: 0.Sin error 1.Datos no encontrados 2.Error al ejecutar la query
idsubcuenta: Identificador de la subcuenta
codsubcuenta: Código de la subcuenta
\end */
function oficial_datosCtaCliente(curFactura:FLSqlCursor, valoresDefecto:Array):Array
{
	return flfactppal.iface.pub_datosCtaCliente( curFactura.valueBuffer("codcliente"), valoresDefecto );
}

/* \D Devuelve el código e id de la subcuenta de proveedor correspondiente a una  determinada factura
@param curFactura: Cursor posicionado en la factura
@param valoresDefecto: Array con los datos de ejercicio y divisa actuales
@return Los datos componen un vector de tres valores:
error: 0.Sin error 1.Datos no encontrados 2.Error al ejecutar la query
idsubcuenta: Identificador de la subcuenta
codsubcuenta: Código de la subcuenta
\end */
function oficial_datosCtaProveedor(curFactura:FLSqlCursor, valoresDefecto:Array):Array
{
	return flfactppal.iface.pub_datosCtaProveedor( curFactura.valueBuffer("codproveedor"), valoresDefecto );
}

/* \D Regenera el asiento correspondiente a una factura de abono de cliente
@param	curFactura: Cursor con los datos de la factura
@param valoresDefecto: Array con los datos de ejercicio y divisa actuales
@return	VERDADERO si no hay error. FALSO en otro caso
\end */
function oficial_asientoFacturaAbonoCli(curFactura:FLSqlCursor, valoresDefecto:Array)
{
	var idAsiento:String  = curFactura.valueBuffer("idasiento").toString();
    var idFactura:String = curFactura.valueBuffer("idfactura");
	var curPartidas:FLSqlCursor = new FLSqlCursor("co_partidas");
	var debe:Number = 0;
	var haber:Number = 0;
	var debeME:Number = 0;
	var haberME:Number = 0;
	var aux:Number;
	var util:FLUtil = new FLUtil;
	
	curPartidas.select("idasiento = '" + idAsiento + "'");
	while (curPartidas.next()) {
		curPartidas.setModeAccess(curPartidas.Edit);
		curPartidas.refreshBuffer();
		debe = parseFloat(curPartidas.valueBuffer("debe"));
		haber = parseFloat(curPartidas.valueBuffer("haber"));
		debeME = parseFloat(curPartidas.valueBuffer("debeme"));
		haberME = parseFloat(curPartidas.valueBuffer("haberme"));
		aux = debe;
		debe = haber * -1;
		haber = aux * -1;
		aux = debeME;
		debeME = haberME * -1;
		haberME = aux * -1;
		debe = util.roundFieldValue(debe, "co_partidas", "debe");
		haber = util.roundFieldValue(haber, "co_partidas", "haber");
		debeME = util.roundFieldValue(debeME, "co_partidas", "debeme");
		haberME = util.roundFieldValue(haberME, "co_partidas", "haberme");

		curPartidas.setValueBuffer("debe",  debe);
		curPartidas.setValueBuffer("haber", haber);
		curPartidas.setValueBuffer("debeme",  debeME);
		curPartidas.setValueBuffer("haberme", haberME);

		if (!curPartidas.commitBuffer())
			return false;
	}
	
	var ctaDevolVentas = this.iface.datosCtaEspecial("DEVVEN", valoresDefecto.codejercicio);
	if (ctaDevolVentas.error == 1) {
		MessageBox.warning(util.translate("scripts", "No tiene definida una subcuenta especial de devoluciones de ventas.\nEl asiento asociado a la factura no puede ser creado"), MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton);
		return false;
	}
	if (ctaDevolVentas.error == 2)
		return false;
	
	var qryPartidasVenta:FLSqlQuery = new FLSqlQuery();
	qryPartidasVenta.setTablesList("co_partidas,co_subcuentas,co_cuentas");
	qryPartidasVenta.setSelect("p.idsubcuenta");
	qryPartidasVenta.setFrom("co_partidas p INNER JOIN co_subcuentas s ON s.idsubcuenta = p.idsubcuenta INNER JOIN co_cuentas c ON c.idcuenta = s.idcuenta ");
	qryPartidasVenta.setWhere("c.idcuentaesp = 'VENTAS' AND idasiento = " + idAsiento);
	try { qryPartidasVenta.setForwardOnly( true ); } catch (e) {}

	if (!qryPartidasVenta.exec())
		return false;

	if (!qryPartidasVenta.next())
		return false;
	
	
	var curPartidasVenta:FLSqlCursor = new FLSqlCursor("co_partidas");
	curPartidasVenta.select("idasiento = " + idAsiento + " AND idsubcuenta = " + qryPartidasVenta.value(0));
	curPartidasVenta.first();
	curPartidasVenta.setModeAccess(curPartidasVenta.Edit);
	curPartidasVenta.refreshBuffer();
	curPartidasVenta.setValueBuffer("idsubcuenta",  ctaDevolVentas.idsubcuenta);
	curPartidasVenta.setValueBuffer("codsubcuenta",  ctaDevolVentas.codsubcuenta);
	if (!curPartidasVenta.commitBuffer())
			return false;
	return true;
}


/* \D Regenera el asiento correspondiente a una factura de abono de proveedor
@param	curFactura: Cursor con los datos de la factura
@param valoresDefecto: Array con los datos de ejercicio y divisa actuales
@return	VERDADERO si no hay error. FALSO en otro caso
\end */
function oficial_asientoFacturaAbonoProv(curFactura:FLSqlCursor, valoresDefecto:Array)
{
	var idAsiento:String  = curFactura.valueBuffer("idasiento").toString();
    var idFactura:String = curFactura.valueBuffer("idfactura");
	var curPartidas:FLSqlCursor = new FLSqlCursor("co_partidas");
	var debe:Number = 0;
	var haber:Number = 0;
	var debeME:Number = 0;
	var haberME:Number = 0;
	var aux:Number;
	
	var util:FLUtil = new FLUtil;
	
	curPartidas.select("idasiento = '" + idAsiento + "'");
	while (curPartidas.next()) {
		curPartidas.setModeAccess(curPartidas.Edit);
		curPartidas.refreshBuffer();
		debe = parseFloat(curPartidas.valueBuffer("debe"));
		haber = parseFloat(curPartidas.valueBuffer("haber"));
		debeME = parseFloat(curPartidas.valueBuffer("debeme"));
		haberME = parseFloat(curPartidas.valueBuffer("haberme"));
		aux = debe;
		debe = haber * -1;
		haber = aux * -1;
		aux = debeME;
		debeME = haberME * -1;
		haberME = aux * -1;
		debe = util.roundFieldValue(debe, "co_partidas", "debe");
		haber = util.roundFieldValue(haber, "co_partidas", "haber");
		debeME = util.roundFieldValue(debeME, "co_partidas", "debeme");
		haberME = util.roundFieldValue(haberME, "co_partidas", "haberme");

		curPartidas.setValueBuffer("debe",  debe);
		curPartidas.setValueBuffer("haber", haber);
		curPartidas.setValueBuffer("debeme",  debeME);
		curPartidas.setValueBuffer("haberme", haberME);
	}
	
	var ctaDevolCompra = this.iface.datosCtaEspecial("DEVCOM", valoresDefecto.codejercicio);
	if (ctaDevolCompra.error == 1) {
		MessageBox.warning(util.translate("scripts", "No tiene definida una subcuenta especial de devoluciones de compras.\nEl asiento asociado a la factura no puede ser creado"), MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton);
		return false;
	}
	if (ctaDevolCompra.error == 2)
		return false;
	
	var qryPartidasCompra:FLSqlQuery = new FLSqlQuery();
	qryPartidasCompra.setTablesList("co_partidas,co_subcuentas,co_cuentas");
	qryPartidasCompra.setSelect("p.idsubcuenta");
	qryPartidasCompra.setFrom("co_partidas p INNER JOIN co_subcuentas s ON s.idsubcuenta = p.idsubcuenta INNER JOIN co_cuentas c ON c.idcuenta = s.idcuenta ");
	qryPartidasCompra.setWhere("c.idcuentaesp = 'COMPRA' AND idasiento = " + idAsiento);
	try { qryPartidasCompra.setForwardOnly( true ); } catch (e) {}

	if (!qryPartidasCompra.exec())
		return false;

	if (!qryPartidasCompra.next())
		return false;
	
	
	var curPartidasCompra:FLSqlCursor = new FLSqlCursor("co_partidas");
	curPartidasCompra.select("idasiento = " + idAsiento + " AND idsubcuenta = " + qryPartidasCompra.value(0));
	curPartidasCompra.first();
	curPartidasCompra.setModeAccess(curPartidasCompra.Edit);
	curPartidasCompra.refreshBuffer();
	curPartidasCompra.setValueBuffer("idsubcuenta",  ctaDevolCompra.idsubcuenta);
	curPartidasCompra.setValueBuffer("codsubcuenta",  ctaDevolCompra.codsubcuenta);
	if (!curPartidasCompra.commitBuffer())
			return false;
	return true;
}

/** \D Si la fecha no está dentro del ejercicio, propone al usuario la selección de uno nuevo
@param	fecha: Fecha del documento
@param	codEjercicio: Ejercicio del documento
@param	tipoDoc: Tipo de documento a generar
@return	Devuelve un array con los siguientes datos:
ok:	Indica si la función terminó correctamente (true) o con error (false)
modificaciones: Indica si se ha modificado algún valor (fecha o ejercicio)
fecha: Nuevo valor para la fecha modificada
codEjercicio: Nuevo valor para el ejercicio modificado
\end */
function oficial_datosDocFacturacion(fecha:String, codEjercicio:String, tipoDoc:String):Array
{
	
	var res:Array = [];
	res["ok"] = true;
	res["modificaciones"] = false;
	
	var util:FLUtil = new FLUtil;
	if (util.sqlSelect("ejercicios", "codejercicio", "codejercicio = '" + codEjercicio + "' AND '" + fecha + "' BETWEEN fechainicio AND fechafin"))
		return res;
		
	var f:Object = new FLFormSearchDB("fechaejercicio");
	var cursor:FLSqlCursor = f.cursor();
	
	cursor.select();
	if (!cursor.first())
		cursor.setModeAccess(cursor.Insert);
	else
		cursor.setModeAccess(cursor.Edit);
	cursor.refreshBuffer();

	cursor.refreshBuffer();
	cursor.setValueBuffer("fecha", fecha);
	cursor.setValueBuffer("codejercicio", codEjercicio);
	cursor.setValueBuffer("label", tipoDoc);
	cursor.commitBuffer();
	cursor.select();

	if (!cursor.first()) {
		res["ok"] = false;
		return res;
	}

	cursor.setModeAccess(cursor.Edit);
	cursor.refreshBuffer();

	f.setMainWidget();
	
	var acpt:String = f.exec("codejercicio");
	if (!acpt) {
		res["ok"] = false;
		return res;
	}
	res["modificaciones"] = true;
	res["fecha"] = cursor.valueBuffer("fecha");
	res["codEjercicio"] = cursor.valueBuffer("codejercicio");
	
	if (res.codEjercicio != flfactppal.iface.pub_ejercicioActual()) {
		if (tipoDoc != "pagosdevolcli" && tipoDoc != "pagosdevolprov") {
			MessageBox.information(util.translate("scripts", "Ha seleccionado un ejercicio distinto del actual.\nPara visualizar los documentos generados debe cambiar el ejercicio actual en la ventana\nde empresa y volver a abrir el formulario maestro correspondiente a los documentos generados"), MessageBox.Ok, MessageBox.NoButton);
		}
	}
	
	return res;
}

/** \C Establece si un documento de cliente debe tener IVA. No lo tendrá si el cliente seleccionado está exento o es UE, o la serie seleccionada sea sin IVA
@param	codSerie: Serie del documento
@param	codCliente: Código del cliente
@return	true si el documento debe llevar IVA, false en caso contrario
\end */
function oficial_tieneIvaDocCliente(codSerie:String, codCliente:String):Boolean
{
	var util:FLUtil = new FLUtil;
	var conIva:Boolean = true;
	
	var regIva:String = util.sqlSelect("clientes", "regimeniva", "codcliente = '" + codCliente + "'");
	if (regIva == "U.E." || regIva == "Exento")
		conIva = false;
		
	if (conIva)
		if (util.sqlSelect("series", "siniva", "codserie = '" + codSerie + "'"))
			conIva = false;
	
	return conIva;
}

/** \D Indica si el módulo de autómata está instalado y activado
@return	true si está activado, false en caso contrario
\end */
function oficial_automataActivado():Boolean
{
	if (!sys.isLoadedModule("flautomata"))
		return false;
	
	if (formau_automata.iface.pub_activado())
		return true;
	
	return false;
}

/** \D Comprueba que si la factura tiene IVA, no esté incluida en un período de regularización ya cerrado
@param	curFactura: Cursor de la factura de cliente o proveedor
@return TRUE si la factura no tiene IVA o teniéndolo su fecha no está incluida en ningún período ya cerrado. FALSE en caso contrario
\end */
function oficial_comprobarRegularizacion(curFactura:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil;

	var fecha:String = curFactura.valueBuffer("fecha");
	if (util.sqlSelect("co_regiva", "idregiva", "fechainicio <= '" + fecha + "' AND fechafin >= '" + fecha + "' AND codejercicio = '" + curFactura.valueBuffer("codejercicio") + "'")) {
		MessageBox.warning(util.translate("scripts", "No puede incluirse el asiento de la factura en un período de I.V.A. ya regularizado"), MessageBox.Ok, MessageBox.NoButton);
		return false;
	}
	return true;
}

/** \D
Recalcula la tabla huecos y el último valor de la secuencia de numeración.
@param serie: Código de serie del documento
@param ejercicio: Código de ejercicio del documento
@param fN: Tipo de documento (factura a cliente, a proveedor, albarán, etc.)
@return true si el calculo se ralizó correctamente
\end */
function oficial_recalcularHuecos( serie:String, ejercicio:String, fN:String ):Boolean {
	var util:FLUtil = new FLUtil;
	var tipo:String;
	var tabla:String;

	if ( fN == "nfacturaprov" ) {
		tipo = "FP";
		tabla = "facturasprov"
	} else if (fN == "nfacturacli") {
		tipo = "FC";
		tabla = "facturascli";
	}

	var idSec = util.sqlSelect( "secuenciasejercicios", "id", "codserie = '" + serie + "' AND codejercicio = '" + ejercicio + "'" );

	if ( idSec ) {
		var nHuecos:Number = parseInt( util.sqlSelect( "huecos", "count(*)", "codserie = '" + serie + "' AND codejercicio = '" + ejercicio + "' AND tipo = '" + tipo + "'" ) );
		var nFacturas:Number = parseInt( util.sqlSelect( tabla, "count(*)", "codserie = '" + serie + "' AND codejercicio = '" + ejercicio + "'" ) );
		var maxFactura:Number = parseInt( util.sqlSelect( "secuencias", "valorout", "id = " + idSec + " AND nombre='" + fN + "'" ) ) - 1;
		if (isNaN(maxFactura))
			maxFactura = 0;

		if ( maxFactura - nFacturas != nHuecos ) {
			var nSec:Number = 0;
			var nFac:Number = 0;
			var ultFac:Number = -1;
			var cursorHuecos:FLSqlCursor = new FLSqlCursor("huecos");
			var qryFac:FLSqlQuery = new FLSqlQuery();

			util.createProgressDialog( util.translate( "scripts", "Calculando huecos en la numeración..." ), maxFactura );

			qryFac.setTablesList( tabla );
			qryFac.setSelect( "numero" );
			qryFac.setFrom( tabla );
			qryFac.setWhere( "codserie = '" + serie + "' AND codejercicio = '" + ejercicio + "'" );
			qryFac.setOrderBy( "codigo asc" );
			qryFac.setForwardOnly( true );

			if ( !qryFac.exec() )
				return true;

			util.sqlDelete( "huecos", "codserie = '" + serie + "' AND codejercicio = '" + ejercicio + "' AND ( tipo = 'XX' OR tipo = '" + tipo + "')" );

			while ( qryFac.next() ) {
				nFac = qryFac.value( 0 );
				
				// Por si hay duplicados, que no debería haberlos...
				if (ultFac == nFac)
					continue;
				ultFac = nFac;
				
				util.setProgress( ++nSec );
				while ( nSec < nFac ) {
					cursorHuecos.setModeAccess( cursorHuecos.Insert );
					cursorHuecos.refreshBuffer();
					cursorHuecos.setValueBuffer( "tipo", tipo );
					cursorHuecos.setValueBuffer( "codserie", serie );
					cursorHuecos.setValueBuffer( "codejercicio", ejercicio );
					cursorHuecos.setValueBuffer( "numero", nSec );
					cursorHuecos.commitBuffer();
					util.setProgress( ++nSec );
				}
			}
			
			util.setProgress( ++nSec );
			util.sqlUpdate( "secuencias", "valorout", nSec, "id = " + idSec + " AND nombre='" + fN + "'" );

			util.setProgress( maxFactura );
			util.destroyProgressDialog();
		}
	}

	return true;
}

/** \D Lanza el formulario que muestra los documentos relacionados con un determinado documento de facturación
@param	codigo: Código del documento
@param	tipo: Tipo del documento
\end */
function oficial_mostrarTraza(codigo:String, tipo:String)
{
	var util:FLUtil = new FLUtil();
	util.sqlDelete("trazadoc", "usuario = '" + sys.nameUser() + "'");

	var f:Object = new FLFormSearchDB("trazadoc");
	var curTraza:FLSqlCursor = f.cursor();
	curTraza.setModeAccess(curTraza.Insert);
	curTraza.refreshBuffer();
	curTraza.setValueBuffer("usuario", sys.nameUser());
	curTraza.setValueBuffer("codigo", codigo);
	curTraza.setValueBuffer("tipo", tipo);
	if (!curTraza.commitBuffer())
		return false;;

	curTraza.select("usuario = '" + sys.nameUser() + "'");
	if (!curTraza.first())
		return false;

	curTraza.setModeAccess(curTraza.Browse);
	f.setMainWidget();
	curTraza.refreshBuffer();
	var acpt:String = f.exec("usuario");
}

/** \D Establece los datos opcionales de una partida de IVA decompras/ventas.
Para facilitar personalizaciones en las partidas.
Se ponen datos de concepto, tipo de documento, documento y factura
@param	curPartida: Cursor sobre la partida
@param	curFactura: Cursor sobre la factura
@param	tipo: cliente / proveedor
@param	concepto: Concepto, opcional
*/
function oficial_datosPartidaFactura(curPartida:FLSqlCursor, curFactura:FLSqlCursor, tipo:String, concepto:String) 
{
	var util:FLUtil = new FLUtil();
	
	if (tipo == "cliente") {
		if (concepto)
			curPartida.setValueBuffer("concepto", concepto);
		else
			curPartida.setValueBuffer("concepto", util.translate("scripts", "Nuestra factura ") + curFactura.valueBuffer("codigo") + " - " + curFactura.valueBuffer("nombrecliente"));
		
		// Si es de IVA
		if (curPartida.valueBuffer("cifnif"))
			curPartida.setValueBuffer("tipodocumento", "Factura de cliente");
	}
	else {
		if (concepto)
			curPartida.setValueBuffer("concepto", concepto);
		else
			curPartida.setValueBuffer("concepto", util.translate("scripts", "Su factura") + curFactura.valueBuffer("codigo") + " - " + curFactura.valueBuffer("nombre"));
		
		// Si es de IVA
		if (curPartida.valueBuffer("cifnif"))
		curPartida.setValueBuffer("tipodocumento", "Factura de proveedor");
	}
	
	// Si es de IVA
	if (curPartida.valueBuffer("cifnif")) {
		curPartida.setValueBuffer("documento", curFactura.valueBuffer("codigo"));
		curPartida.setValueBuffer("factura", curFactura.valueBuffer("numero"));
	}
}

/** \D Comprueba si hay condiciones para regenerar los recibos de una factura
cuando se edita la misma. Para sobrecargar en extensiones
@param	curFactura: Cursor de la factura
@param	masCampos: Array con los nombres de campos adicionales. Opcional
@return	VERDADERO si hay que regenerar, FALSO en otro caso
\end */
function oficial_siGenerarRecibosCli(curFactura:FLSqlCursor, masCampos:Array):Boolean 
{
	var camposAcomprobar = new Array("codcliente","total","codpago","fecha");
	
	for (var i:Number = 0; i < camposAcomprobar.length; i++)
		if (curFactura.valueBuffer(camposAcomprobar[i]) != curFactura.valueBufferCopy(camposAcomprobar[i]))
			return true;
	
	if (masCampos) {
		for (i = 0; i < masCampos.length; i++)
			if (curFactura.valueBuffer(masCampos[i]) != curFactura.valueBufferCopy(masCampos[i]))
				return true;
	}
	
	return false;
}

function oficial_validarIvaRecargoCliente(codCliente:String,id:Number,tabla:String,identificador:String):Boolean
{
	var util:FLUtil;

	if(!codCliente)
		return true;	

	var regimenIva = util.sqlSelect("clientes","regimeniva","codcliente = '" + codCliente + "'");
	var aplicarRecargo = util.sqlSelect("clientes","recargo","codcliente = '" + codCliente + "'");
	
	var q:FLSqlQuery = new FLSqlQuery();
	q.setTablesList(tabla);
	q.setSelect("iva,recargo");
	q.setFrom(tabla);
	q.setWhere(identificador + " = " + id);
	
	if (!q.exec())
		return false;

	while (q.next()) {
				var iva:Number = parseFloat(q.value("iva"));
		if(!iva)
			iva = 0;
		var recargo:Number = parseFloat(q.value("recargo"));
		if(!recargo)
			recargo = 0;

		switch (regimenIva) {
			case "General":
			case "U.E.": {
				if (iva <= 0) {
					var res:Number = MessageBox.warning(util.translate("scripts", "El cliente %1 tiene establecido un régimen de I.V.A. %2\ny en alguna o varias de las lineas no hay establecido un % de I.V.A.\n¿Desea continuar de todas formas?").arg(codCliente).arg(regimenIva), MessageBox.Yes,MessageBox.No);
					if (res != MessageBox.Yes)
						return false;
				}
			}
			break;
			case "Exento": {
				if (iva != 0) {
					var res:Number = MessageBox.warning(util.translate("scripts", "El cliente %1 tiene establecido un régimen de I.V.A. %2\ny en alguna o varias de las lineas hay establecido un % de I.V.A.\n¿Desea continuar de todas formas?").arg(codCliente).arg(regimenIva), MessageBox.Yes,MessageBox.No);
					if (res != MessageBox.Yes)
						return false;
				}
			}
			break;
		}
		if (aplicarRecargo && recargo <= 0) {
			var res:Number = MessageBox.warning(util.translate("scripts", "Al cliente %1 se le debe aplicar Recargo de Equivalencia\ny en alguna o varias de las lineas no hay establecido un % de R. Equivalencia.\n¿Desea continuar de todas formas?").arg(codCliente), MessageBox.Yes,MessageBox.No);
				if (res != MessageBox.Yes)
					return false;
		}
		if (!aplicarRecargo && recargo != 0) {
			var res:Number = MessageBox.warning(util.translate("scripts", "Al cliente %1 no se le debe aplicar Recargo de Equivalencia\ny en alguna o varias de las lineas hay establecido un % de R. Equivalencia.\n¿Desea continuar de todas formas?").arg(codCliente), MessageBox.Yes,MessageBox.No);
				if (res != MessageBox.Yes)
					return false;
		}
	}

	return true;
}

function oficial_validarIvaRecargoProveedor(codProveedor:String,id:Number,tabla:String,identificador:String):Boolean
{
	var util:FLUtil;

	if(!codProveedor)
		return true;	

	var regimenIva = util.sqlSelect("proveedores","regimeniva","codproveedor = '" + codProveedor + "'");
	var aplicarRecargo = util.sqlSelect("empresa","recequivalencia","1 = 1");
	
	var q:FLSqlQuery = new FLSqlQuery();
	q.setTablesList(tabla);
	q.setSelect("iva,recargo");
	q.setFrom(tabla);
	q.setWhere(identificador + " = " + id);
	
	if (!q.exec())
		return false;

	while (q.next()) {
		var iva:Number = parseFloat(q.value("iva"));
		if(!iva)
			iva = 0;
		var recargo:Number = parseFloat(q.value("recargo"));
		if(!recargo)
			recargo = 0;

		switch (regimenIva) {
			case "General":
			case "U.E.": {
				if (q.value("iva") <= 0) {
					var res:Number = MessageBox.warning(util.translate("scripts", "El proveedor %1 tiene establecido un régimen de I.V.A. %2\ny en alguna o varias de las lineas no hay establecido un % de I.V.A.\n¿Desea continuar de todas formas?").arg(codProveedor).arg(regimenIva), MessageBox.Yes,MessageBox.No);
					if (res != MessageBox.Yes)
						return false;
				}
			}
			break;
			case "Exento": {
				if (q.value("iva") != 0) {
					var res:Number = MessageBox.warning(util.translate("scripts", "El proveedor %1 tiene establecido un régimen de I.V.A. %2\ny en alguna o varias de las lineas hay establecido un % de I.V.A.\n¿Desea continuar de todas formas?").arg(codProveedor).arg(regimenIva), MessageBox.Yes,MessageBox.No);
					if (res != MessageBox.Yes)
						return false;
				}
			}
			break;
		}
		if (aplicarRecargo && q.value("recargo") <= 0) {
			var res:Number = MessageBox.warning(util.translate("scripts", "En los datos de empresa está activa al opción Aplicar Recargo de Equivalencia\ny en alguna o varias de las lineas no hay establecido un % de R. Equivalencia.\n¿Desea continuar de todas formas?"), MessageBox.Yes,MessageBox.No);
				if (res != MessageBox.Yes)
					return false;
		}
		if (!aplicarRecargo && q.value("recargo") != 0) {
			var res:Number = MessageBox.warning(util.translate("scripts", "En los datos de empresa no está activa al opción Aplicar Recargo de Equivalencia\ny en alguna o varias de las lineas hay establecido un % de R. Equivalencia.\n¿Desea continuar de todas formas?"), MessageBox.Yes,MessageBox.No);
				if (res != MessageBox.Yes)
					return false;
		}
	}

	return true;
}
//// OFICIAL ////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////

//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
