# Change Log
Todos los cambios en el template serán documentados en este archivo
 
## [Flutter 3.13.4] - 2023-09-12
 
Here we write upgrading notes for brands. It's a team effort to make them as
straightforward as possible.
 
### Added
- Changelog.md
- Librería import_sorter.
 
### Changed
- DropdownButton2: cambio en la organización de sus argumentos
- flutter_template\lib\src\support\network\network.dart: DioError deprecado -> DioException
 
### Fixed
- Cambios por flutter lints

## [QueryCriteria, FilterCriterion, SortCriterion] - 2024-02-15
 
Here we write upgrading notes for brands. It's a team effort to make them as
straightforward as possible.
 
### Fixed
En las clases QueryCriteria, FilterCriterion y SortCriterion se actualizaron las siguientes propiedades para que correspondan con los filtros en la query esperados por API:
- QueryCriteria: "sort" cambio a "sorts" y "filter" cambio a "filters".
- FilterCriterion y SortCriterion: "property" cambio a "propertyName".

## [LoadingPopup] - 2024-03-1
 
Here we write upgrading notes for brands. It's a team effort to make them as
straightforward as possible.
 
### Fixed
En el loading popup:
- Bloqueo del back para cerrar el popup
- Remplazo del container que cubria todo la pantalla con el fin de evitar el cierre del popup, por el barrierDissmisible = false y barrierColor = kPrimary

