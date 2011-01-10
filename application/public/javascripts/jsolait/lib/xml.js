
Module("xml","$Revision: 36 $",function(mod){
mod.XMLNS="http://www.w3.org/2000/xmlns/";
mod.NSXML="http://www.w3.org/XML/1998/namespace";
mod.nsPrefixMap={"http://www.w3.org/2000/xmlns/":"xmlns","http://www.w3.org/XML/1998/namespace":"xml"};
mod.NoXMLParser=Class(mod.Exception,function(publ,supr){
publ.__init__=function(trace){
supr.__init__.call(this,"Could not create an XML parser.",trace);
};
});
mod.ParsingFailed=Class(mod.Exception,function(publ,supr){
publ.__init__=function(xml,trace){
supr.__init__.call(this,"Failed parsing XML document.",trace);
this.xml=xml;
};
publ.xml;
});
mod.parseXML=function(xml){
var obj=null;
var isMoz=false;
var isIE=false;
var isASV=false;
try{
var p=window.parseXML;
if(p==null){
throw "No ASV paseXML";
}
isASV=true;
}catch(e){
try{
obj=new DOMParser();
isMoz=true;
}catch(e){
try{
obj=new ActiveXObject("Msxml2.DomDocument.4.0");isIE=true;
}catch(e){
try{
obj=new ActiveXObject("Msxml2.DomDocument");isIE=true;
}catch(e){
try{
obj=new ActiveXObject("microsoft.XMLDOM");isIE=true;
throw new mod.NoXMLParser(e);
}
}
}
}
}
try{
if(isMoz){
obj=obj.parseFromString(xml,"text/xml");
return obj;
}else if(isIE){
obj.loadXML(xml);
return obj;
}else if(isASV){
return window.parseXML(xml,null);
}
}catch(e){
throw new mod.ParsingFailed(xml,e);
}
};
mod.importNode=function(importedNode,deep){
var ELEMENT_NODE=1;
var n=mod.importNode(srcNode.childNodes.item(i),true);
break;
var attr=this.importNode(importedNode.attributes.item(i),deep);
var getNSPrefix=function(node,namespaceURI,nsPrefixMap){
if(!namespaceURI){
return "";
}else if(mod.nsPrefixMap[namespaceURI]){
return mod.nsPrefixMap[namespaceURI]+":";
}else if(nsPrefixMap[namespaceURI]!=null){
return nsPrefixMap[namespaceURI]+":";
}
if(node.nodeType==1){
for(var i=0;i<node.attributes.length;i++){
var attr=node.attributes.item(i);
return attr.localName+":";
}
}
}else{
throw new Error("Cannot find a namespace prefix for "+namespaceURI);
}
if(node.parentNode){
return getNSPrefix(node.parentNode,namespaceURI,nsPrefixMap);}else{
throw new Error("Cannot find a namespace prefix for "+namespaceURI);
}
};
mod.node2XML=function(node,nsPrefixMap,attrParent){
nsPrefixMap=(nsPrefixMap==null)?{}:nsPrefixMap;
try{
var nsprefix=getNSPrefix(attrParent,node.namespaceURI,nsPrefixMap);
}catch(e){
alert(node.namespaceURI+"\n"+e.message);
}
if(nsprefix+node.localName=="xmlns:xmlns"){
nsprefix="";
}s+=nsprefix+node.localName+'="'+node.value+'"';
if(node.documentElement!=null){
s+=this.node2XML(node.documentElement,nsPrefixMap);
}
break;
s+="<"+node.tagName;
for(var i=0;i<node.attributes.length;i++){
s+=" "+this.node2XML(node.attributes.item(i),nsPrefixMap,node);
s+="</"+node.tagName+">\n";
}
case ENTITY_REFERENCE_NODE:
});