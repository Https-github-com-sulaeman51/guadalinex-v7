/***************************************************************************
                 masterfacturasprov.qs  -  description
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
	function recordDelBeforefacturasprov() { return this.ctx.interna_recordDelBeforefacturasprov(); }
}
//// INTERNA /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
class oficial extends interna {
	var pbnAFactura:Object;
	var tdbRecords:FLTableDB;
	var tbnImprimir:Object;
    function oficial( context ) { interna( context ); } 
	function imprimir(codFactura:String) {
		return this.ctx.oficial_imprimir(codFactura);
	}
	function commonCalculateField(fN:String, cursor:FLSqlCursor):String {
		return this.ctx.oficial_commonCalculateField(fN, cursor);
	}
	function liberarAlbaranes(idFactura:Number) {
		return this.ctx.oficial_liberarAlbaranes(idFactura);
	}
	function liberarAlbaran(idAlbaran:Number) {
		return this.ctx.oficial_liberarAlbaran(idAlbaran);
	}
	function asociarAFactura() {
		return this.ctx.oficial_asociarAFactura();
	}
	function whereAgrupacion(curAgrupar:FLSqlCursor):String {
		return this.ctx.oficial_whereAgrupacion(curAgrupar);
	}
	function sinIVA(cursor:FLSqlCursor):Boolean {
		return this.ctx.oficial_sinIVA(cursor);
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
	function pub_commonCalculateField(fN:String, cursor:FLSqlCursor):String {
		return this.commonCalculateField(fN, cursor);
	}
	function pub_whereAgrupacion(curAgrupar:FLSqlCursor):String {
		return this.whereAgrupacion(curAgrupar);
	}
	function pub_imprimir(codFactura:String) {
		return this.imprimir(codFactura);
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
Este es el formulario maestro de facturas a proveedor.
\end */
function interna_init()
{
	this.iface.pbnAFactura = this.child("pbnAsociarAFactura");
	this.iface.tdbRecords= this.child("tableDBRecords");
	this.iface.tbnImprimir = this.child("toolButtonPrint");

	connect(this.iface.pbnAFactura, "clicked()", this, "iface.asociarAFactura()");
	connect(this.iface.tbnImprimir, "clicked()", this, "iface.imprimir");

	var codEjercicio = flfactppal.iface.pub_ejercicioActual();
	if (codEjercicio)
		this.cursor().setMainFilter("codejercicio = '" + codEjercicio + "'");

}

/** \C
Al borrar una factura, su código será agregado a la tabla de huecos para que pueda ser reutilizado en futuras facturas
\end */
function interna_recordDelBeforefacturasprov()
{
		var cursor:FLSqlCursor = this.cursor();
		this.iface.liberarAlbaranes(cursor.valueBuffer("idfactura"));
		flfacturac.iface.pub_agregarHueco(cursor.valueBuffer("codserie"), cursor.valueBuffer("codejercicio"), cursor.valueBuffer("numero"), "nfacturaprov");
}

//// INTERNA /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
/** \C
Al pulsar el botón imprimir se lanzará el informe correspondiente a la factura seleccionada (en caso de que el módulo de informes esté cargado)
\end */
function oficial_imprimir(codFactura:String)
{
	if (sys.isLoadedModule("flfactinfo")) {
		var codigo:String;
		if (codFactura) {
			codigo = codFactura;
		} else {
			if (!this.cursor().isValid())
				return;
			codigo = this.cursor().valueBuffer("codigo");
		}
		var curImprimir:FLSqlCursor = new FLSqlCursor("i_facturasprov");
		curImprimir.setModeAccess(curImprimir.Insert);
		curImprimir.refreshBuffer();
		curImprimir.setValueBuffer("descripcion", "temp");
		curImprimir.setValueBuffer("d_facturasprov_codigo", codigo);
		curImprimir.setValueBuffer("h_facturasprov_codigo", codigo);
		flfactinfo.iface.pub_lanzarInforme(curImprimir, "i_facturasprov");
	} else
		flfactppal.iface.pub_msgNoDisponible("Informes");
}

function oficial_commonCalculateField(fN:String, cursor:FLSqlCursor):String
{
	var util:FLUtil = new FLUtil();
	var valor:String;

	/** \C
	El --código-- se construye como la concatenación de --codserie--, --codejercicio-- y --numero--
	\end */
	if (fN == "codigo")
		valor = flfacturac.iface.pub_construirCodigo(cursor.valueBuffer("codserie"), cursor.valueBuffer("codejercicio"), cursor.valueBuffer("numero"));

	switch (fN) {
	/** \C
	El --total-- es el --neto-- menos el --totalirpf-- más el --totaliva-- más el --totalrecargo-- más el --recfinanciero--
	\end */
	case "total": {
			var neto:Number = parseFloat(cursor.valueBuffer("neto"));
			var totalIva:Number = parseFloat(cursor.valueBuffer("totaliva"));
			var totalIrpf:Number = parseFloat(cursor.valueBuffer("totalirpf"));
			var totalRecargo:Number = parseFloat(cursor.valueBuffer("totalrecargo"));
			var recFinanciero:Number = (parseFloat(cursor.valueBuffer("recfinanciero")) * neto) / 100;
			recFinanciero = parseFloat(util.roundFieldValue(recFinanciero, "facturasprov", "total"));
			valor = neto - totalIrpf + totalIva + totalRecargo + recFinanciero;
			valor = parseFloat(util.roundFieldValue(valor, "facturasprov", "total"));
			break;
		}
		/** \C
		El --totaleuros-- es el producto del --total-- por la --tasaconv--
		\end */
		case "totaleuros": {
			var total:Number = parseFloat(cursor.valueBuffer("total"));
			var tasaConv:Number = parseFloat(cursor.valueBuffer("tasaconv"));
			valor = total * tasaConv;
			valor = parseFloat(util.roundFieldValue(valor, "facturasprov", "totaleuros"));
			break;
		}
		/** \C
		El --neto-- es la suma del pvp total de las líneas de albarán
		\end */
		case "neto": {
			valor = util.sqlSelect("lineasfacturasprov", "SUM(pvptotal)", "idfactura = " + cursor.valueBuffer("idfactura"));
			valor = parseFloat(util.roundFieldValue(valor, "facturasprov", "neto"));
			break;
		}
		/** \C
		El --totaliva-- es la suma del iva correspondiente a las líneas de albarán
		\end */
		case "totaliva": {
			if (this.iface.sinIVA(cursor))
				valor = 0;
			else {
				valor = util.sqlSelect("lineasfacturasprov", "SUM((pvptotal * iva) / 100)", "idfactura = " + cursor.valueBuffer("idfactura"));
				valor = parseFloat(util.roundFieldValue(valor, "facturasprov", "totaliva"));
			}
			break;
		}
		/** \C
		El --totarecargo-- es la suma del recargo correspondiente a las líneas de albarán
		\end */
		case "totalrecargo": {
			if (this.iface.sinIVA(cursor))
				valor = 0;
			else {
				valor = util.sqlSelect("lineasfacturasprov", "SUM((pvptotal * recargo) / 100)", "idfactura = " + cursor.valueBuffer("idfactura"));
				valor = parseFloat(util.roundFieldValue(valor, "facturasprov", "totalrecargo"));
			}
			break;
		}
		/** \C
		El --irpf-- es el asociado al --codserie-- del albarán
		\end */
		case "irpf": {
			valor = util.sqlSelect("series", "irpf", "codserie = '" + cursor.valueBuffer("codserie") + "'");
			break;
		}
		/** \C
		El --totalirpf-- es el producto del --irpf-- por el --neto--
		\end */
		case "totalirpf": {
			valor = (parseFloat(cursor.valueBuffer("irpf")) * (parseFloat(cursor.valueBuffer("neto")))) / 100;
			valor = parseFloat(util.roundFieldValue(valor, "facturascli", "totalirpf"));
			break;
		}
	}
	return valor;
}

/** \D
Llama a la función liberarAlbaran para todos los albaranes agrupados en una factura
@param idFactura: Identificador de la factura
\end */
function oficial_liberarAlbaranes(idFactura:Number)
{
		var curAlbaranes:FLSqlCursor = new FLSqlCursor("albaranesprov");
		curAlbaranes.select("idfactura = " + idFactura);
		while (curAlbaranes.next())
				this.iface.liberarAlbaran(curAlbaranes.valueBuffer("idalbaran"));
}

/** \D
Desbloquea un albarán que estaba asociado a una factura
@param idAlbaran: Identificador del albarán
\end */
function oficial_liberarAlbaran(idAlbaran:Number)
{
		var curAlbaran:FLSqlCursor = new FLSqlCursor("albaranesprov");
		with(curAlbaran) {
				select("idalbaran = " + idAlbaran);
				first();
				setUnLock("ptefactura", true);
				setModeAccess(Edit);
				refreshBuffer();
				setValueBuffer("idfactura", "0");
				commitBuffer();
		}
}

/** \C
Al pulsar el botón de asociar a factura se abre la ventana de agrupar albaranes de proveedor
\end */
function oficial_asociarAFactura()
{
		var util:FLUtil = new FLUtil;
		var f:Object = new FLFormSearchDB("agruparalbaranesprov");
		var cursor:FLSqlCursor = f.cursor();
		var where:String;
		var codProveedor:String;
		var codAlmacen:String;

		cursor.setActivatedCheckIntegrity(false);
		cursor.select();
		if (!cursor.first())
				cursor.setModeAccess(cursor.Insert);
		else
				cursor.setModeAccess(cursor.Edit);

		f.setMainWidget();
		cursor.refreshBuffer();
		var acpt:String = f.exec("codejercicio");
		if (acpt) {
				cursor.commitBuffer();

				var curAgruparAlbaranes:FLSqlCursor = new FLSqlCursor("agruparalbaranesprov");
				curAgruparAlbaranes.select();
				if (curAgruparAlbaranes.first()) {
						where = this.iface.whereAgrupacion(curAgruparAlbaranes);
						var excepciones:FLSqlCursor = curAgruparAlbaranes.valueBuffer("excepciones");
						if (!excepciones.isEmpty())
								where += " AND idalbaran NOT IN (" + excepciones + ")";
								
						var qryAgruparAlbaranes:FLSqlQuery = new FLSqlQuery;
						qryAgruparAlbaranes.setTablesList("albaranesprov");
						qryAgruparAlbaranes.setSelect("codproveedor,codalmacen");
						qryAgruparAlbaranes.setFrom("albaranesprov");
						qryAgruparAlbaranes.setWhere(where + " GROUP BY codproveedor,codalmacen");

						if (!qryAgruparAlbaranes.exec())
								return;

						var totalProv:Number = qryAgruparAlbaranes.size();
						util.createProgressDialog(util.translate("scripts", "Generando facturas"), totalProv);
						util.setProgress(1);
						var j:Number = 0;
						
						var curAlbaran:FLSqlCursor = new FLSqlCursor("albaranesprov");
						var whereFactura:String;
						while (qryAgruparAlbaranes.next()) {
								codProveedor = qryAgruparAlbaranes.value(0);
								codAlmacen = qryAgruparAlbaranes.value(1);
								whereFactura = where + " AND codproveedor = '" + codProveedor + "'" + " AND codalmacen = '" + codAlmacen + "'";
								curAlbaran.transaction(false);
								curAlbaran.select(whereFactura);
								if (!curAlbaran.first()) {
										curAlbaran.rollback();
										util.destroyProgressDialog();
										return;
								}
								curAlbaran.setValueBuffer("fecha", curAgruparAlbaranes.valueBuffer("fecha"));
								if (formalbaranesprov.iface.pub_generarFactura(whereFactura, curAlbaran)) {
										curAlbaran.commit();
								} else {
										curAlbaran.rollback();
										util.destroyProgressDialog();
										return;
								}
								util.setProgress(++j);
						}
						util.setProgress(totalProv);
						util.destroyProgressDialog();
				}

				f.close();
				this.iface.tdbRecords.refresh();
		}
}

/** \D
Construye la sentencia WHERE de la consulta que buscará los albaranes a agrupar
@param curAgrupar: Cursor de la tabla agruparalbaranescli que contiene los valores de los criterios de búsqueda
@return Sentencia where
\end */
function oficial_whereAgrupacion(curAgrupar:FLSqlCursor):String
{
		var codProveedor:String = curAgrupar.valueBuffer("codproveedor");
		var nombre:String = curAgrupar.valueBuffer("nombre");
		var cifNif:String = curAgrupar.valueBuffer("cifnif");
		var codAlmacen:String = curAgrupar.valueBuffer("codalmacen");
		var codPago:String = curAgrupar.valueBuffer("codpago");
		var codDivisa:String = curAgrupar.valueBuffer("coddivisa");
		var codSerie:String = curAgrupar.valueBuffer("codserie");
		var codEjercicio:String = curAgrupar.valueBuffer("codejercicio");
		var fechaDesde:String = curAgrupar.valueBuffer("fechadesde");
		var fechaHasta:String = curAgrupar.valueBuffer("fechahasta");
		var where:String = "ptefactura = 'true'";
		if (codProveedor && !codProveedor.isEmpty())
				where += " AND codproveedor = '" + codProveedor + "'";
		if (cifNif && !cifNif.isEmpty())
				where += " AND cifnif = '" + cifNif + "'";
		if (codAlmacen && !codAlmacen.isEmpty())
				where = where + " AND codalmacen = '" + codAlmacen + "'";
		where = where + " AND fecha >= '" + fechaDesde + "'";
		where = where + " AND fecha <= '" + fechaHasta + "'";
		if (codPago && !codPago.isEmpty())
				where = where + " AND codpago = '" + codPago + "'";
		if (codDivisa && !codDivisa.isEmpty())
				where = where + " AND coddivisa = '" + codDivisa + "'";
		if (codSerie && !codSerie.isEmpty())
				where = where + " AND codserie = '" + codSerie + "'";
		if (codEjercicio && !codEjercicio.isEmpty())
				where = where + " AND codejercicio = '" + codEjercicio + "'";

		return where;
}

function oficial_sinIVA(cursor:FLSqlCursor):Boolean
{
	var util:FLUtil = new FLUtil();
	
	var serie:String = cursor.valueBuffer("codserie");
	if (util.sqlSelect("series","siniva","codserie = '" + serie + "'"))
		return true;
	
	var codProveedor:String = cursor.valueBuffer("codproveedor");
	var regimenIVA:String = util.sqlSelect("proveedores", "regimeniva", "codproveedor = '" + codProveedor + "'");
	if (regimenIVA == "Exento" || regimenIVA == "UE")
		return true;
	
	return false;
}

//// OFICIAL /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////

//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
