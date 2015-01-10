//add your implemented constraint here
fact {
	(all p:Publication |p.type = JA implies one p.journal implies not p.book and not p.proceedings) or
	(all p:Publication |p.type = BC implies one p.book implies not p.journal and not p.proceedings) or
 	(all p:Publication |p.type = CP implies one p.proceedings implies not p.book and not p.journal) or
	(all p:Publication |p.type = WP implies one p.proceedings implies not p.book and not p.journal)
}