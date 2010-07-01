/***************************************************************************
                 impuestos.qs  -  description
                             -------------------
    begin                : jue dic 23 2004
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
}
//// INTERNA /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
class oficial extends interna {
	var posActualPuntoSubRep:Number;
	var posActualPuntoSubSop:Number;
	var posActualPuntoSubAcr:Number;
	var posActualPuntoSubDeu:Number;
	var longSubcuenta:Number;
	var bloqueoSubcuenta:Boolean;
    function oficial( context ) { interna( context ); } 
	function bufferChanged(fN) { return this.ctx.oficial_bufferChanged(fN); }
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
function interna_init()
{
	var util:FLUtil = new FLUtil();
	var cursor:FLSqlCursor = this.cursor();
	
	connect(cursor, "bufferChanged(QString)", this, "iface.bufferChanged");

	var ejercicioActual:String = flfactppal.iface.pub_ejercicioActual();
	this.child("fdbIdSubcuentaRep").setFilter("codejercicio = '" + ejercicioActual + "'");
	this.child("fdbIdSubcuentaSop").setFilter("codejercicio = '" + ejercicioActual + "'");
	this.child("fdbIdSubcuentaAcr").setFilter("codejercicio = '" + ejercicioActual + "'");
	this.child("fdbIdSubcuentaDeu").setFilter("codejercicio = '" + ejercicioActual + "'");

/** \C Si el módulo de contabilidad está cargado, se habilita el campo de cuenta de ventas
\end */
	if (!sys.isLoadedModule("flcontppal"))
		this.child("gbxContabilidad").enabled = false;
	else {
		this.iface.longSubcuenta = util.sqlSelect("ejercicios", "longsubcuenta",  "codejercicio = '" + ejercicioActual + "'");
		this.iface.posActualPuntoSubRep = -1;
		this.iface.posActualPuntoSubSop = -1;
		this.iface.posActualPuntoSubAcr = -1;
		this.iface.posActualPuntoSubDeu = -1;
		this.iface.bloqueoSubcuenta = false;
	}	
}
//// INTERNA /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
function oficial_bufferChanged(fN)
{
	var cursor:FLSqlCursor = this.cursor();
	switch(fN) {
		/*U Al introducir un código de subcuenta, si el usuario pulsa la tecla del punto '.', la subcuenta se informa automaticamente con el código de cuenta más tantos ceros como sea necesario para completar la longitud de subcuenta asociada al ejercicio actual.
		\end */
		case "codsubcuentarep":{
				if (!this.iface.bloqueoSubcuenta) {
					this.iface.bloqueoSubcuenta = true;
					this.iface.posActualPuntoSubRep = flcontppal.iface.pub_formatearCodSubcta(this, "fdbCodSubcuentaRep", this.iface.longSubcuenta, this.iface.posActualPuntoSubRep);
					this.iface.bloqueoSubcuenta = false;
			}
			break;
		}
		case "codsubcuentasop":{
				if (!this.iface.bloqueoSubcuenta) {
					this.iface.bloqueoSubcuenta = true;
					this.iface.posActualPuntoSubSop = flcontppal.iface.pub_formatearCodSubcta(this, "fdbCodSubcuentaSop", this.iface.longSubcuenta, this.iface.posActualPuntoSubSop);
					this.iface.bloqueoSubcuenta = false;
			}
			break;
		}
		case "codsubcuentaacr":{
				if (!this.iface.bloqueoSubcuenta) {
					this.iface.bloqueoSubcuenta = true;
					this.iface.posActualPuntoSubAcr = flcontppal.iface.pub_formatearCodSubcta(this, "fdbCodSubcuentaAcr", this.iface.longSubcuenta, this.iface.posActualPuntoSubAcr);
					this.iface.bloqueoSubcuenta = false;
			}
			break;
		}
		case "codsubcuentadeu":{
				if (!this.iface.bloqueoSubcuenta) {
					this.iface.bloqueoSubcuenta = true;
					this.iface.posActualPuntoSubDeu = flcontppal.iface.pub_formatearCodSubcta(this, "fdbCodSubcuentaDeu", this.iface.longSubcuenta, this.iface.posActualPuntoSubDeu);
					this.iface.bloqueoSubcuenta = false;
			}
			break;
		}
	}
}
//// OFICIAL /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////

//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
