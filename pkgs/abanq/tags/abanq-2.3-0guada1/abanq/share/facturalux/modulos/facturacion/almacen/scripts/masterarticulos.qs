/***************************************************************************
                 masterarticulos.qs  -  description
                             -------------------
    begin                : jue jun 28 2007
    copyright            : (C) 2007 by InfoSiAL S.L.
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
}
//// INTERNA /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
class oficial extends interna {
	var curArticulo:FLSqlCursor;
	var tdbRecords:FLTableDB;
	var toolButtonCopy:Object;
	function oficial( context ) { interna( context ); }
	function copiarArticulo_clicked() {
		return this.ctx.oficial_copiarArticulo_clicked();
	}
	function copiarArticulo():String {
		return this.ctx.oficial_copiarArticulo();
	}
	function copiarAnexosArticulo(nuevaReferencia:String):Boolean {
		return this.ctx.oficial_copiarAnexosArticulo(nuevaReferencia);
	}
	function copiarTablaTarifas(nuevaReferencia:String):Boolean {
		return this.ctx.oficial_copiarTablaTarifas(nuevaReferencia);
	}
	function copiarTablaArticulosProv(nuevaReferencia:String):Boolean {
		return this.ctx.oficial_copiarTablaArticulosProv(nuevaReferencia);
	}
	function datosArticulo(cursor:FLSqlCursor,referencia:String):Boolean {
		return this.ctx.oficial_datosArticulo(cursor,referencia);
	}
	function copiarTarifa(id:Number,referencia:String):Number {
		return this.ctx.oficial_copiarTarifa(id,referencia);
	}
	function datosTarifa(cursor:FLSqlCursor,cursorNuevo:FLSqlCursor,referencia:String):Boolean {
		return this.ctx.oficial_datosTarifa(cursor,cursorNuevo,referencia);
	}
	function copiarArticuloProv(id:Number,referencia:String):Number {
		return this.ctx.oficial_copiarArticuloProv(id,referencia);
	}
	function datosArticuloProv(cursor:FLSqlCursor,cursorNuevo:FLSqlCursor,referencia:String):Boolean {
		return this.ctx.oficial_datosArticuloProv(cursor,cursorNuevo,referencia);
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
/** \C El Al copiar un artículo se copian también sus tarifas y sus precios por proveedor.
\end */
function interna_init()
{
	this.iface.curArticulo = this.cursor();
	this.iface.tdbRecords = this.child("tableDBRecords");
	this.iface.toolButtonCopy = this.child("toolButtonCopy");
	connect(this.iface.toolButtonCopy, "clicked()", this, "iface.copiarArticulo_clicked()");
}
//// INTERNA /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
function oficial_copiarArticulo_clicked()
{
	var util:FLUtil;
	var cursor:FLSqlCursor = this.cursor();
	var referencia:String = this.iface.curArticulo.valueBuffer("referencia");
	cursor.transaction(false);

	if (!referencia) {
		MessageBox.information(util.translate("scripts", "No hay ningún registro seleccionado"), MessageBox.Ok, MessageBox.NoButton);
		return;
	}

	try {
		if (this.iface.copiarArticulo())
			cursor.commit();
		else
			cursor.rollback();
	}
	catch (e) {
		cursor.rollback();
		MessageBox.critical(util.translate("scripts", "Hubo un error al copiar el artículo ") + referencia + ":\n" + e, MessageBox.Ok, MessageBox.NoButton);
	}
	
	this.iface.tdbRecords.refresh();

	return true;
}

function oficial_copiarArticulo():String
{
	
	var util:FLUtil;

    var nuevaReferencia = Input.getText( "Introduzca la nueva referencia:","","Copiar Artículo");
    if (nuevaReferencia && nuevaReferencia != "") {
		if (util.sqlSelect("articulos","referencia","referencia = '" + nuevaReferencia + "'")) {
			MessageBox.warning(util.translate("scripts", "Ya existe un artículo con esa referencia"), MessageBox.Ok, MessageBox.NoButton);
			return false;
		}

		var curNuevoArticulo:FLSqlCursor = new FLSqlCursor("articulos");
		curNuevoArticulo.setModeAccess(curNuevoArticulo.Insert);
		curNuevoArticulo.refreshBuffer();

		if (!this.iface.datosArticulo(curNuevoArticulo,nuevaReferencia))
			return false;

		if (!curNuevoArticulo.commitBuffer())
				return false;

		if (!this.iface.copiarAnexosArticulo(nuevaReferencia))
			return false;

    }
	else {
		MessageBox.warning(util.translate("scripts", "Debe introducir una referencia para crear el nuevo artículo."), MessageBox.Ok, MessageBox.NoButton);
        return false;
    }

	return nuevaReferencia;
}

function oficial_copiarAnexosArticulo(nuevaReferencia:String):Boolean
{
	if (!this.iface.copiarTablaTarifas(nuevaReferencia))
		return false;
	
	if (!this.iface.copiarTablaArticulosProv(nuevaReferencia))
		return false;
	
	return true;
}

function oficial_copiarTablaTarifas(nuevaReferencia:String):Boolean
{
		var q:FLSqlQuery = new FLSqlQuery();
		q.setTablesList("articulostarifas");
		q.setSelect("id");
		q.setFrom("articulostarifas");
		q.setWhere("referencia = '" + this.iface.curArticulo.valueBuffer("referencia") + "'");
		
		if (!q.exec())
			return false;

		while (q.next()) {
			if (!this.iface.copiarTarifa(q.value("id"),nuevaReferencia))
				return false;
		}

	return true;
}
		
function oficial_copiarTablaArticulosProv(nuevaReferencia:String):Boolean
{
		var q:FLSqlQuery = new FLSqlQuery();
		q.setTablesList("articulosprov");
		q.setSelect("id");
		q.setFrom("articulosprov");
		q.setWhere("referencia = '" + this.iface.curArticulo.valueBuffer("referencia") + "'");
		
		if (!q.exec())
			return false;

		while (q.next()) {
			if (!this.iface.copiarArticuloProv(q.value("id"),nuevaReferencia))
				return false;
		}

	return true;
}

function oficial_datosArticulo(cursor:FLSqlCursor,referencia:String):Boolean 
{
	cursor.setValueBuffer("referencia",referencia);
	cursor.setValueBuffer("descripcion",this.iface.curArticulo.valueBuffer("descripcion"));
	cursor.setValueBuffer("pvp",this.iface.curArticulo.valueBuffer("pvp"));

	var codImpuesto:String = this.iface.curArticulo.valueBuffer("codimpuesto");
	if(codImpuesto)
		cursor.setValueBuffer("codimpuesto",codImpuesto);

	var codFamilia:String = this.iface.curArticulo.valueBuffer("codfamilia");
	if(codFamilia)
		cursor.setValueBuffer("codfamilia",codFamilia);	

	cursor.setValueBuffer("tipocodbarras",this.iface.curArticulo.valueBuffer("tipocodbarras"));
	cursor.setValueBuffer("imagen",this.iface.curArticulo.valueBuffer("imagen"));
	cursor.setValueBuffer("stockmax",this.iface.curArticulo.valueBuffer("stockmax"));
	cursor.setValueBuffer("stockmin",this.iface.curArticulo.valueBuffer("stockmin"));
	cursor.setValueBuffer("stockfis",0);
	cursor.setValueBuffer("costemedio",this.iface.curArticulo.valueBuffer("costemedio"));
	cursor.setValueBuffer("controlstock",this.iface.curArticulo.valueBuffer("controlstock"));
	cursor.setValueBuffer("observaciones",this.iface.curArticulo.valueBuffer("observaciones"));
	cursor.setValueBuffer("codsubcuentacom",this.iface.curArticulo.valueBuffer("codsubcuentacom"));

	var idSubcuentaCom:String = this.iface.curArticulo.valueBuffer("idsubcuentacom");
	if(idSubcuentaCom)
		cursor.setValueBuffer("idsubcuentacom",idSubcuentaCom);

	cursor.setValueBuffer("codsubcuentairpfcom",this.iface.curArticulo.valueBuffer("codsubcuentairpfcom"));

	var idSubcuentaIrpfCom:String = this.iface.curArticulo.valueBuffer("idsubcuentairpfcom");
	if(idSubcuentaIrpfCom)
		cursor.setValueBuffer("idsubcuentairpfcom",idSubcuentaIrpfCom);

	return true;
}

function oficial_copiarTarifa(id:Number,referencia:String):Number
{
	var curTarifa:FLSqlCursor = new FLSqlCursor("articulostarifas");
	curTarifa.select("id = " + id);
	if (!curTarifa.first())
		return false;
	curTarifa.setModeAccess(curTarifa.Edit);
	curTarifa.refreshBuffer();
	
	var curTarifaNueva:FLSqlCursor = new FLSqlCursor("articulostarifas");
	curTarifaNueva.setModeAccess(curTarifa.Insert);
	curTarifaNueva.refreshBuffer();

	if (!this.iface.datosTarifa(curTarifa,curTarifaNueva,referencia))
		return false;

	if (!curTarifaNueva.commitBuffer())
		return false;

	var idNuevo:Number = curTarifaNueva.valueBuffer("id");

	return idNuevo;
}

function oficial_datosTarifa(cursor:FLSqlCursor,cursorNuevo:FLSqlCursor,referencia:String):Boolean
{
	cursorNuevo.setValueBuffer("codtarifa",cursor.valueBuffer("codtarifa"));
	cursorNuevo.setValueBuffer("referencia",referencia);
	cursorNuevo.setValueBuffer("pvp",cursor.valueBuffer("pvp"));

	return true;
}

function oficial_copiarArticuloProv(id:Number,referencia:String):Number
{
	var curArticuloProv:FLSqlCursor = new FLSqlCursor("articulosprov");
	curArticuloProv.select("id = " + id);
	if (!curArticuloProv.first())
		return false;
	curArticuloProv.setModeAccess(curArticuloProv.Edit);
	curArticuloProv.refreshBuffer();
	
	var curArticuloProvNuevo:FLSqlCursor = new FLSqlCursor("articulosprov");
	curArticuloProvNuevo.setModeAccess(curArticuloProvNuevo.Insert);
	curArticuloProvNuevo.refreshBuffer();

	if (!this.iface.datosArticuloProv(curArticuloProv,curArticuloProvNuevo,referencia))
		return false;

	if (!curArticuloProvNuevo.commitBuffer())
		return false;

	var idNuevo:Number = curArticuloProvNuevo.valueBuffer("id");

	return idNuevo;
}

function oficial_datosArticuloProv(cursor:FLSqlCursor,cursorNuevo:FLSqlCursor,referencia:String):Boolean
{
	cursorNuevo.setValueBuffer("referencia",referencia);
	cursorNuevo.setValueBuffer("codproveedor",cursor.valueBuffer("codproveedor"));
	cursorNuevo.setValueBuffer("nombre",cursor.valueBuffer("nombre"));
	cursorNuevo.setValueBuffer("coste",cursor.valueBuffer("coste"));
	cursorNuevo.setValueBuffer("coddivisa",cursor.valueBuffer("coddivisa"));
	cursorNuevo.setValueBuffer("refproveedor",cursor.valueBuffer("refproveedor"));

	return true;
}
//// OFICIAL /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////

//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
