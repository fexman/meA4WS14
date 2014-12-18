package sample

import java.io.File
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator

class SampleGenerator implements IGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		val model = resource.contents.get(0) as Model
		val name = new File(resource.URI.toFileString).name.replace(".sample", ".txt")
		fsa.generateFile(
			name,
			'''
				«FOR p : model.elements»
					This is information generated from: «p.name»
				«ENDFOR»
			'''
		)

		for (p : model.elements) {
			fsa.generateFile(p.name + ".txt", "Look a file is generated for " + p.name)
		}

		fsa.generateFile(
			"additionalFile.txt",
			model.generateCode
		)
	}

	def dispatch generateCode(Model myModel) '''
		public model
		«FOR Element el : myModel.elements»
			«el.generateCode»
		«ENDFOR»
		'''

	def dispatch generateCode(Element myElement) '''
		element «myElement.hashCode»: «myElement.name.toFirstLower»; '''

}
