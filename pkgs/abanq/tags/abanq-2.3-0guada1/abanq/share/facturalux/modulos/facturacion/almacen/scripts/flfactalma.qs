/***************************************************************************
                 flfactalma.qs  -  description
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
	function init() { this.ctx.interna_init(); }
	function afterCommit_stocks(curStock:FLSqlCursor):Boolean {
		return this.ctx.interna_afterCommit_stocks(curStock);
	}
	function beforeCommit_stocks(curStock:FLSqlCursor):Boolean {
		return this.ctx.interna_beforeCommit_stocks(curStock);
	}
	function afterCommit_lineastransstock(curLTS:FLSqlCursor):Boolean {
		return this.ctx.interna_afterCommit_lineastransstock(curLTS);
	}
}
//// INTERNA /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
class oficial extends interna {
	function oficial( context ) { interna( context ); } 
	function cambiarStock(codAlmacen:String, referencia:String, variacion:Number):Boolean {
		return this.ctx.oficial_cambiarStock(codAlmacen, referencia, variacion);
	}
	function cambiarCosteMedio(referencia:String):Boolean {
		return this.ctx.oficial_cambiarCosteMedio(referencia);
	}
	function controlStockPedidosCli(curLP:FLSqlCursor):Boolean {
		return this.ctx.oficial_controlStockPedidosCli(curLP);
	}
	function controlStockAlbaranesCli(curLA:FLSqlCursor):Boolean {
		return this.ctx.oficial_controlStockAlbaranesCli(curLA);
	}
	function controlStockAlbaranesProv(curLA:FLSqlCursor):Boolean {
		return this.ctx.oficial_controlStockAlbaranesProv(curLA);
	}
	function controlStockFacturasCli(curLF:FLSqlCursor):Boolean {
		return this.ctx.oficial_controlStockFacturasCli(curLF);
	}
	function controlStockComandasCli(curLV:FLSqlCursor):Boolean {
		return this.ctx.oficial_controlStockComandasCli(curLV);
	}
	function controlStockFacturasProv(curLF:FLSqlCursor):Boolean {
		return this.ctx.oficial_controlStockFacturasProv(curLF);
	}
	function crearStock(codAlmacen:String, referencia:String):Number {
		return this.ctx.oficial_crearStock(codAlmacen, referencia);
	}
	function controlStockLineasTrans(curLTS:FLSqlCursor):Boolean {
		return this.ctx.oficial_controlStockLineasTrans(curLTS);
	}
	function controlStockValesTPV(curLinea:FLSqlCursor):Boolean {
		return this.ctx.oficial_controlStockValesTPV(curLinea);
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
	function pub_cambiarStock(codAlmacen:String, referencia:String, variacion:Number):Boolean {
		return this.cambiarStock(codAlmacen, referencia, variacion);
	}
	function pub_crearStock(codAlmacen:String, referencia:String):Number {
		return this.crearStock(codAlmacen, referencia);
	}
	function pub_cambiarCosteMedio(referencia:String):Boolean {
		return this.cambiarCosteMedio(referencia);
	}
	function pub_controlStockPedidosCli(curLP:FLSqlCursor):Boolean {
		return this.controlStockPedidosCli(curLP);
	}
	function pub_controlStockAlbaranesCli(curLA:FLSqlCursor):Boolean {
		return this.controlStockAlbaranesCli(curLA);
	}
	function pub_controlStockAlbaranesProv(curLA:FLSqlCursor):Boolean {
		return this.controlStockAlbaranesProv(curLA);
	}
	function pub_controlStockFacturasCli(curLF:FLSqlCursor):Boolean {
		return this.controlStockFacturasCli(curLF);
	}
	function pub_controlStockComandasCli(curLV:FLSqlCursor):Boolean {
		return this.controlStockComandasCli(curLV);
	}
	function pub_controlStockFacturasProv(curLF:FLSqlCursor):Boolean {
		return this.controlStockFacturasProv(curLF);
	}
	function pub_controlStockValesTPV(curLinea:FLSqlCursor):Boolean {
		return this.controlStockValesTPV(curLinea);
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
/** \D Si no hay ningún almacén en la tabla almacenes se inserta uno por defecto
\end */
function interna_init()
{
	var cursor:FLSqlCursor = new FLSqlCursor("almacenes");
	cursor.select();
	if (!cursor.first()) {
		var util:FLUtil = new FLUtil();
		MessageBox.information(util.translate("scripts",
			"Se insertará un almacén por defecto para empezar a trabajar."),
			MessageBox.Ok, MessageBox.NoButton, MessageBox.NoButton);
		with (cursor) {
			setModeAccess(Insert);
			refreshBuffer();
			setValueBuffer("codalmacen","ALG");
			setValueBuffer("nombre", util.translate("scripts","ALMACEN GENERAL"));
			commitBuffer();
		}
	}

	cursor = new FLSqlCursor("empresa");
	cursor.select();
	if (cursor.first()) {
		with (cursor) {
			setModeAccess(cursor.Edit);
			refreshBuffer();
			if (!valueBuffer("codalmacen")) {
				setValueBuffer("codalmacen","ALG");
				commitBuffer();
			}
		}
	}
}

/** \D
Actualiza el stock físico total en la tabla de artículos
\end */
function interna_afterCommit_stocks(curStock:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil;
	var referencia:String = curStock.valueBuffer("referencia");
	var stockFisico:Number = util.sqlSelect("stocks", "SUM(cantidad)", "referencia = '" + referencia + "'");
	switch (curStock.modeAccess()) {
		case curStock.Edit:
			var refAnterior:String = curStock.valueBufferCopy("referencia");
			if (referencia != refAnterior) {
				if (!util.sqlUpdate("articulos", "stockfis", stockFisico, "referencia = '" + refAnterior + "'"))
					return false;
			}
		case curStock.Insert:
		case curStock.Del:
			if (!util.sqlUpdate("articulos", "stockfis", stockFisico, "referencia = '" + referencia + "'"))
				return false;
	}
	return true;
}

/** \D
Avisa al usuario en caso de querer borrar un stock con cantidad distinta de 0
\end */
function interna_beforeCommit_stocks(curStock:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil;
	switch (curStock.modeAccess()) {
		case curStock.Del: {
			if (parseFloat(curStock.valueBuffer("cantidad")) != 0) {
				var res:Number = MessageBox.warning(util.translate("scripts", "Va a eliminar un registro de stock con cantidad distinta de 0.\n¿Está seguro?"), MessageBox.No, MessageBox.Yes);
				if (res != MessageBox.Yes)
					return false;
			}
		}
	}
	return true;
}

function interna_afterCommit_lineastransstock(curLTS:FLSqlCursor):Boolean {
	return this.iface.controlStockLineasTrans(curLTS);
}

//// INTERNA /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
/** \D Cambia el valor del stock en un determinado almacén. Se comprueba si el valor de la variación es negativo y mayor al stock actual, en cuyo caso se avisa al usuario de la falta de existencias

@param codAlmacen Código del almacén
@param referencia Referencia del artículo
@param variación Variación en el número de existencias del artículo
@return True si la modificación tuvo éxito, false en caso contrario
\end */
function oficial_cambiarStock(codAlmacen:String, referencia:String, variacion:Number):Boolean
{
	var util:FLUtil = new FLUtil();
	if (referencia == "" || !referencia)
		return true;

	var cantidadPrevia:Number;
	var controlStock:Boolean;
	var curStock:FLSqlCursor = new FLSqlCursor("stocks");
	curStock.select("referencia = '" + referencia + "' AND codalmacen = '" + codAlmacen + "'");
	var hayStock:Boolean = curStock.first();
	if (hayStock) {
		curStock.setModeAccess(curStock.Edit);
		curStock.refreshBuffer();
		cantidadPrevia = parseFloat(curStock.valueBuffer("cantidad"));
	} else
		cantidadPrevia = 0;
	var nuevaCantidad:Number = cantidadPrevia + parseFloat(variacion);
	if (parseFloat(nuevaCantidad) < 0) {
		controlStock = util.sqlSelect("articulos", "controlstock", "referencia = '" + referencia + "'");
		if (controlStock == false) {
			MessageBox.warning(util.translate("scripts", "No hay stock suficiente para el artículo %1 en el almacén %2").arg(referencia).arg(codAlmacen), MessageBox.Ok, MessageBox.NoButton);
			return false;
		}
	}

	var nombreAlmacen:String = util.sqlSelect("almacenes", "nombre", "codalmacen = '" + codAlmacen + "'");
	if (!hayStock) {
		curStock.setModeAccess(curStock.Insert);
		curStock.refreshBuffer();
		curStock.setValueBuffer("referencia", referencia);
		curStock.setValueBuffer("codalmacen", codAlmacen);
	}
	curStock.setValueBuffer("nombre", nombreAlmacen);
	curStock.setValueBuffer("cantidad", nuevaCantidad);
	curStock.commitBuffer();
	return true;
}

/** \D Recalcula el coste medio de compra de un artículo como media del coste en todos los albaranes de proveedor

@param referencia Referencia del artículo
@return True si la modificación tuvo éxito, false en caso contrario
\end */
function oficial_cambiarCosteMedio(referencia:String):Boolean
{
	if (referencia == "")
		return true;

	var util:FLUtil = new FLUtil();
	var sumCant:Number = util.sqlSelect("lineasfacturasprov", "SUM(cantidad)", "referencia = '" + referencia + "'");
	if ( !sumCant )
		return true;
	var cM:Number = util.sqlSelect("lineasfacturasprov", "(SUM(pvptotal) / SUM(cantidad))", "referencia = '" + referencia + "'");
	if (!cM)
		cM = 0;

	var curArticulo:FLSqlCursor = new FLSqlCursor("articulos");
	curArticulo.select("referencia = '" + referencia + "'");
	if (curArticulo.first()) {
		curArticulo.setModeAccess(curArticulo.Edit);
		curArticulo.refreshBuffer();
		curArticulo.setValueBuffer("costemedio", cM);
		curArticulo.commitBuffer();
	}

	return true;
}

/** \C
Actualiza el stock correspondiente al artículo seleccionado en la línea
\end */
function oficial_controlStockPedidosCli(curLP:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil();
	var codAlmacen:String = util.sqlSelect("pedidoscli", "codalmacen", "idpedido = " + curLP.valueBuffer("idpedido"));
	if (!codAlmacen || codAlmacen == "")
		return true;
	
	switch(curLP.modeAccess()) {
		case curLP.Insert:
			var cantidad:Number = -1 * parseFloat(curLP.valueBuffer("cantidad"));
			if (!this.iface.cambiarStock(codAlmacen, curLP.valueBuffer("referencia"), cantidad))
				return false;
			break;
		case curLP.Del:
			if (!this.iface.cambiarStock(codAlmacen, curLP.valueBuffer("referencia"), curLP.valueBuffer("cantidad")))
				return false;
			break;
		case curLP.Edit:
			if (curLP.valueBuffer("referencia") != curLP.valueBufferCopy("referencia")
				|| curLP.valueBuffer("cantidad") != curLP.valueBufferCopy("cantidad")) {
				var cantidad:Number = -1 * parseFloat(curLP.valueBuffer("cantidad"));
				if (this.iface.cambiarStock(codAlmacen, curLP.valueBufferCopy("referencia"), curLP.valueBufferCopy("cantidad"))) {
					if (!this.iface.cambiarStock(codAlmacen, curLP.valueBuffer("referencia"), cantidad))
						return false;
				} else
					return false;
			}
			break;
	}
	return true;
}

/** \C
Actualiza el stock correspondiente al artículo seleccionado en la línea
en caso de que no venga de un pedido, o que la opción general de control
de stocks en pedidos esté inhabilitada
\end */
function oficial_controlStockAlbaranesCli(curLA:FLSqlCursor):Boolean
{
	if (curLA.valueBuffer("idlineapedido") != 0 && flfactppal.iface.pub_valorDefectoEmpresa("stockpedidos"))
		return true;

	var util:FLUtil = new FLUtil();
	var codAlmacen:String = util.sqlSelect("albaranescli", "codalmacen", "idalbaran = " + curLA.valueBuffer("idalbaran"));
	if (!codAlmacen || codAlmacen == "")
		return true;
		
	switch(curLA.modeAccess()) {
		case curLA.Insert:
			var cantidad:Number = -1 * parseFloat(curLA.valueBuffer("cantidad"));
			if (!this.iface.cambiarStock(codAlmacen, curLA.valueBuffer("referencia"), cantidad))
					return false;
			break;
		case curLA.Del:
			if (!this.iface.cambiarStock(codAlmacen, curLA.valueBuffer("referencia"), curLA.valueBuffer("cantidad")))
					return false;
			break;
		case curLA.Edit:
			if (curLA.valueBuffer("referencia") != curLA.valueBufferCopy("referencia")
				|| curLA.valueBuffer("cantidad") != curLA.valueBufferCopy("cantidad")) {
				var cantidad:Number = -1 * parseFloat(curLA.valueBuffer("cantidad"));
				if (this.iface.cambiarStock(codAlmacen, curLA.valueBufferCopy("referencia"), curLA.valueBufferCopy("cantidad"))) {
					if (!this.iface.cambiarStock(codAlmacen, curLA.valueBuffer("referencia"), cantidad))
						return false;
				} else
					return false;
			}
			break;
	}
	return true;
}

/** \C
Actualiza el stock correspondiente al artículo seleccionado en la línea
\end */
function oficial_controlStockFacturasCli(curLF:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil();
	var automatica:Boolean = util.sqlSelect("facturascli", "automatica", "idfactura = " + curLF.valueBuffer("idfactura"));
	if (automatica == false) {
		var codAlmacen = util.sqlSelect("facturascli", "codalmacen", "idfactura = " + curLF.valueBuffer("idfactura"));
		if (!codAlmacen || codAlmacen == "")
			return true;
		
		switch(curLF.modeAccess()) {
			case curLF.Insert:
				var cantidad:Number = -1 * parseFloat(curLF.valueBuffer("cantidad"));
				if (!this.iface.cambiarStock(codAlmacen, curLF.valueBuffer("referencia"), cantidad))
						return false;
				break;
			case curLF.Del:
				if (!this.iface.cambiarStock(codAlmacen, curLF.valueBuffer("referencia"), curLF.valueBuffer("cantidad")))
					return false;
				break;
			case curLF.Edit:
				if (curLF.valueBuffer("referencia") != curLF.valueBufferCopy("referencia") || curLF.valueBuffer("cantidad") != curLF.valueBufferCopy("cantidad")) {
					var cantidad:Number = -1 * parseFloat(curLF.valueBuffer("cantidad"));
					if (this.iface.cambiarStock(codAlmacen, curLF.valueBufferCopy("referencia"), curLF.valueBufferCopy("cantidad"))) {
						if (!this.iface.cambiarStock(codAlmacen, curLF.valueBuffer("referencia"), cantidad))
								return false;
					} else
						return false;
				}
				break;
		}
	}
	return true;
}

/** \C
Actualiza el stock correspondiente al artículo seleccionado en la línea
\end */
function oficial_controlStockComandasCli(curLV:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil();
	var codAlmacen = util.sqlSelect("tpv_comandas c INNER JOIN tpv_puntosventa pv ON c.codtpv_puntoventa = pv.codtpv_puntoventa", "pv.codalmacen", "idtpv_comanda = " + curLV.valueBuffer("idtpv_comanda"), "tpv_comandas,tpv_puntosventa");
	if (!codAlmacen || codAlmacen == "")
		return true;
	
	switch(curLV.modeAccess()) {
		case curLV.Insert: {
			var cantidad:Number = -1 * parseFloat(curLV.valueBuffer("cantidad"));
			if (!this.iface.cambiarStock(codAlmacen, curLV.valueBuffer("referencia"), cantidad))
				return false;
			break;
		}
		case curLV.Del: {
			if (!this.iface.cambiarStock(codAlmacen, curLV.valueBuffer("referencia"), curLV.valueBuffer("cantidad")))
				return false;
			break;
		}
		case curLV.Edit: {
			if (curLV.valueBuffer("referencia") != curLV.valueBufferCopy("referencia") || curLV.valueBuffer("cantidad") != curLV.valueBufferCopy("cantidad")) {
				var cantidad:Number = -1 * parseFloat(curLV.valueBuffer("cantidad"));
				if (this.iface.cambiarStock(codAlmacen, curLV.valueBufferCopy("referencia"), curLV.valueBufferCopy("cantidad"))) {
					if (!this.iface.cambiarStock(codAlmacen, curLV.valueBuffer("referencia"), cantidad))
							return false;
				} else
					return false;
			}
			break;
		}
	}
	
	return true;
}

/** \C
Actualiza el stock correspondiente al artículo seleccionado en la línea
\end */
function oficial_controlStockAlbaranesProv(curLA:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil();
	var codAlmacen:String = util.sqlSelect("albaranesprov", "codalmacen", "idalbaran = " + curLA.valueBuffer("idalbaran"));
	if (!codAlmacen || codAlmacen == "")
		return true;
	
	switch(curLA.modeAccess()) {
		case curLA.Insert:
			if (!this.iface.cambiarStock(codAlmacen, curLA.valueBuffer("referencia"), curLA.valueBuffer("cantidad")))
				return false;
			break;
		case curLA.Del: {
			var cantidad:Number = -1 * parseFloat(curLA.valueBuffer("cantidad"));
			if (!this.iface.cambiarStock(codAlmacen, curLA.valueBuffer("referencia"), cantidad))
				return false;
			break;
		}
		case curLA.Edit:
			if (curLA.valueBuffer("referencia") != curLA.valueBufferCopy("referencia") || curLA.valueBuffer("cantidad") != curLA.valueBufferCopy("cantidad")) {
				var cantidad:Number = -1 * parseFloat(curLA.valueBufferCopy("cantidad"));
				if (this.iface.cambiarStock(codAlmacen, curLA.valueBufferCopy("referencia"), cantidad)) {
					if (!this.iface.cambiarStock(codAlmacen, curLA.valueBuffer("referencia"), curLA.valueBuffer("cantidad")))
						return false;
				} else
					return false;
			}
			break;
	}
	return true;
}

/** \C
Actualiza el stock correspondiente al artículo seleccionado en la línea
\end */
function oficial_controlStockFacturasProv(curLF:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil;
	var automatica:Boolean = util.sqlSelect("facturasprov", "automatica", "idfactura = " + curLF.valueBuffer("idfactura"));
	if (automatica == false) {
		var codAlmacen:String = util.sqlSelect("facturasprov", "codalmacen", "idfactura = " + curLF.valueBuffer("idfactura"));
		if (!codAlmacen || codAlmacen == "")
			return true;
			
		switch(curLF.modeAccess()) {
			case curLF.Insert:
				if (!this.iface.cambiarStock(codAlmacen, curLF.valueBuffer("referencia"), curLF.valueBuffer("cantidad")))
					return false;
				break;
			case curLF.Del:
				var cantidad:Number = -1 * parseFloat(curLF.valueBuffer("cantidad"));
				if (!this.iface.cambiarStock(codAlmacen, curLF.valueBuffer("referencia"), cantidad))
					return false;
				break;
			case curLF.Edit:
				if (curLF.valueBuffer("referencia") != curLF.valueBufferCopy("referencia") || curLF.valueBuffer("cantidad") != curLF.valueBufferCopy("cantidad")) {
					var cantidad:Number = -1 * parseFloat(curLF.valueBufferCopy("cantidad"));
					if (this.iface.cambiarStock(codAlmacen, curLF.valueBufferCopy("referencia"), cantidad)) {
						if (!this.iface.cambiarStock(codAlmacen, curLF.valueBuffer("referencia"), curLF.valueBuffer("cantidad")))
							return false;
					} else
						return false;
				}
				break;
		}
	}
	return true;
}

/** \D Crea un registro de stock para el almacén y artículo especificados
@param	codAlmacen: Almacén
@param	referencia: Referencia del artículo
@return	identificador del stock o false si hay error
\end */
function oficial_crearStock(codAlmacen:String, referencia:String):Number
{
	var util:FLUtil = new FLUtil;
	var curStock:FLSqlCursor = new FLSqlCursor("stocks");
	with(curStock) {
		setModeAccess(Insert);
		refreshBuffer();
		setValueBuffer("codalmacen", codAlmacen);
		setValueBuffer("referencia", referencia);
		setValueBuffer("nombre", util.sqlSelect("almacenes", "nombre", "codalmacen = '" + codAlmacen + "'"));
		setValueBuffer("cantidad", 0);
		if (!commitBuffer())
			return false;
	}
	return curStock.valueBuffer("idstock");
}

/** \C
Actualiza el stock correspondiente al artículo seleccionado en la línea
\end */
function oficial_controlStockLineasTrans(curLTS:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil();
	var codAlmacenOrigen:String = util.sqlSelect("transstock", "codalmaorigen", "idtrans = " + curLTS.valueBuffer("idtrans"));
	if (!codAlmacenOrigen || codAlmacenOrigen == "")
		return true;
		
	var codAlmacenDestino:String = util.sqlSelect("transstock", "codalmadestino", "idtrans = " + curLTS.valueBuffer("idtrans"));
	if (!codAlmacenDestino || codAlmacenDestino == "")
		return true;
	
	var cantidad:Number = parseFloat(curLTS.valueBuffer("cantidad"));
	var referencia:String = curLTS.valueBuffer("referencia");
	switch(curLTS.modeAccess()) {
		case curLTS.Insert:
			if (!this.iface.cambiarStock(codAlmacenOrigen, referencia, (-1 * cantidad)))
				return false;
			if (!this.iface.cambiarStock(codAlmacenDestino, referencia, cantidad))
				return false;
			break;
		case curLTS.Del:
			if (!this.iface.cambiarStock(codAlmacenOrigen, referencia, cantidad))
				return false;
			if (!this.iface.cambiarStock(codAlmacenDestino, referencia, (-1 * cantidad)))
				return false;
			break;
		case curLTS.Edit:
			if (referencia != curLTS.valueBufferCopy("referencia") || cantidad != curLTS.valueBufferCopy("cantidad")) {
				var cantidadPrevia:Number = parseFloat(curLTS.valueBufferCopy("cantidad"));
				if (!this.iface.cambiarStock(codAlmacenOrigen, curLTS.valueBufferCopy("referencia"), cantidadPrevia))
					return false;
				if (!this.iface.cambiarStock(codAlmacenOrigen, referencia, (-1 * cantidad)))
					return false;
				if (!this.iface.cambiarStock(codAlmacenDestino, curLTS.valueBufferCopy("referencia"), (-1 * cantidadPrevia)))
					return false;
				if (!this.iface.cambiarStock(codAlmacenDestino, referencia, cantidad))
					return false;
			}
			break;
	}
	return true;
}

/** \C
Actualiza el stock correspondiente al artículo seleccionado en la línea
\end */
function oficial_controlStockValesTPV(curLinea:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil();
	var codAlmacen:String = curLinea.valueBuffer("codalmacen");
	if (!codAlmacen || codAlmacen == "")
		return true;
	
	switch(curLinea.modeAccess()) {
		case curLinea.Insert:
			if (!this.iface.cambiarStock(codAlmacen, curLinea.valueBuffer("referencia"), curLinea.valueBuffer("cantidad")))
				return false;
			break;
		case curLinea.Del: {
			var cantidad:Number = -1 * parseFloat(curLinea.valueBuffer("cantidad"));
			if (!this.iface.cambiarStock(codAlmacen, curLinea.valueBuffer("referencia"), cantidad))
				return false;
			break;
		}
		case curLinea.Edit: {
			if (curLinea.valueBuffer("referencia") != curLinea.valueBufferCopy("referencia") || curLinea.valueBuffer("cantidad") != curLinea.valueBufferCopy("cantidad")) {
				var cantidad:Number = -1 * parseFloat(curLinea.valueBufferCopy("cantidad"));
				if (this.iface.cambiarStock(codAlmacen, curLinea.valueBufferCopy("referencia"), cantidad)) {
					if (!this.iface.cambiarStock(codAlmacen, curLinea.valueBuffer("referencia"), curLinea.valueBuffer("cantidad")))
						return false;
				} else
					return false;
			}
			break;
		}
	}
	return true;
}

//// OFICIAL /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////

//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
