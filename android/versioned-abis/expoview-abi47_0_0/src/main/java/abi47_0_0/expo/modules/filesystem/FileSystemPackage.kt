package abi47_0_0.expo.modules.filesystem

import android.content.Context
import abi47_0_0.expo.modules.core.BasePackage
import abi47_0_0.expo.modules.core.ExportedModule
import abi47_0_0.expo.modules.core.interfaces.InternalModule

class FileSystemPackage : BasePackage() {
  override fun createInternalModules(context: Context): List<InternalModule> =
    listOf(FilePermissionModule(), AppDirectoriesModule(context))

  override fun createExportedModules(context: Context): List<ExportedModule> =
    listOf<ExportedModule>(FileSystemModule(context))
}
