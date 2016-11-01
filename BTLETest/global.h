//
//  global.h
//  BTLETools
//
//  Created by Tijn Kooijmans on 03/04/14.
//
//

#ifndef BTLETools_global_h
#define BTLETools_global_h

#define IS_IPAD ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)

#ifdef TARGET_TV

static const CGFloat bigCellHeight = 100;
static const CGFloat defaultCellHeight = 88;
static NSString *defaultStoryboard = @"Main_TV";

#define CELL_BOLD_TITLE_FONT         [UIFont systemFontOfSize: 38]
#define CELL_TITLE_FONT         [UIFont systemFontOfSize: 38]
#define CELL_SUBTITLE_FONT     [UIFont systemFontOfSize: 38]

#else

static const CGFloat bigCellHeight = 50;
static const CGFloat defaultCellHeight = 44;
static NSString *defaultStoryboard = @"Main";

#define CELL_BOLD_TITLE_FONT         [UIFont boldSystemFontOfSize: 18]
#define CELL_TITLE_FONT         [UIFont systemFontOfSize: 18]
#define CELL_SUBTITLE_FONT     [UIFont systemFontOfSize: 12]

#endif

#endif
