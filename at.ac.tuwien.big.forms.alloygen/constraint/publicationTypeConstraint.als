//add your implemented constraint here
fact {
	(all p:Publication | p.type = JA => no(p.journal - Journal) and no(p.book) and no(p.proceedings)) and 
	(all p:Publication | p.type = BC => no(p.book - Book) and no(p.journal) and no(p.proceedings)) and 
	(all p:Publication | (p.type = WP or p.type = CP) => no(p.proceedings - Proceedings) and no(p.book) and no(p.journal))
}