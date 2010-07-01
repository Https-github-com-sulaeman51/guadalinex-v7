/***************************************************************************
                 i_masterinventario.qs  -  description
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
}
//// INTERNA /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
class oficial extends interna {
    function oficial( context ) { interna( context ); } 
		function lanzar() {
				return this.ctx.oficial_lanzar();
		}
		function obtenerOrden(nivel:Number, cursor:FLSqlCursor):String {
				return this.ctx.oficial_obtenerOrden(nivel, cursor);
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
	function pub_lanzar() {
		return this.lanzar();
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
function interna_init()
{
		connect (this.child("toolButtonPrint"), "clicked()", this, "iface.lanzar()");
}

//// INTERNA /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
function oficial_lanzar()
{
		var cursor:FLSqlCursor = this.cursor();
		var seleccion:String = cursor.valueBuffer("id");
		if (!seleccion)
				return;
				
		var nombreInforme:String = cursor.action();
		var orderBy:String = "";
		var o:String = "";
		for (var i:Number = 1; i < 3; i++) {
				o = this.iface.obtenerOrden(i, cursor);
				if (o) {
						if (orderBy == "")
								orderBy = o;
						else
								orderBy += ", " + o;
				}
		}
		flfactinfo.iface.pub_lanzarInforme(cursor, nombreInforme, orderBy);
}

function oficial_obtenerOrden(nivel:Number, cursor:FLSqlCursor):String
{
	var ret:String = "";
	var orden:String = cursor.valueBuffer("orden" + nivel.toString());
	switch(nivel) {
			case 1: {
					switch(orden) {
						case "Código": {
							ret += "almacenes.codalmacen";
							break;
						}
						case "Nombre": {
							ret += "almacenes.nombre";
							break;
						}
					}
					break;
			}
			break;
			case 2: {
					switch(orden) {
						case "Referencia": {
							ret += "stocks.referencia";
							break;
						}
						case "Descripción": {
							ret += "articulos.descripcion";
							break;
						}
					}
					break;
			}
			break;
	}
	if (ret != "") {
			var tipoOrden:String = cursor.valueBuffer("tipoorden" + nivel.toString());
			switch(tipoOrden) {
					case "Descendente": {
							ret += " DESC";
							break;
					}
			}
	}

	if (nivel == 1 && orden != 1) {
			if (ret == "")
					ret += "almacenes.codalmacen";
			else
					ret += ", almacenes.codalmacen";
	}

	return ret;
}

//// OFICIAL /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////

//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
