/***************************************************************************
                 co_masterasientos.qs  -  description
                             -------------------
    begin                : jue jul 22 2004
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
	var pteAsientoPre:Boolean;
	var tdbRecords:FLTableDB;
	var ejercicioActual:String;
	
	function oficial( context ) { interna( context ); } 
	function pendientePre():Boolean {
		return this.ctx.oficial_pendientePre();
	}
	function establecerPendientePre(pte:Boolean) {
		return this.ctx.oficial_establecerPendientePre(pte);
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
	function pub_pendientePre() {
		return this.pendientePre();
	}
	function pub_establecerPendientePre(pte:Boolean) {
		return this.establecerPendientePre(pte);
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
/** \C El formulario mostrará los asientos asociados al ejercicio actual
\end */
function interna_init()
{
		var util:FLUtil = new FLUtil();
		var cursor:FLSqlCursor = this.cursor();

		this.iface.tdbRecords = this.child("tableDBRecords");
		this.iface.ejercicioActual = flfactppal.iface.pub_ejercicioActual();
		this.iface.pteAsientoPre = false;
		
		cursor.setMainFilter("codEjercicio = '" + this.iface.ejercicioActual + "'");
		this.iface.tdbRecords.refresh();
}
//// INTERNA /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
function oficial_pendientePre():Boolean
{
	return this.iface.pteAsientoPre;
}

function oficial_establecerPendientePre(pte:Boolean)
{
	this.iface.pteAsientoPre = pte;
}
//// OFICIAL /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
