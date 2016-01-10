/* $Id: TET_head.h,v 1.5 2015/07/29 12:07:39 rjs Exp $
 *
 * Wrapper code for the TET Objective-C binding
 *
 */

#import <Foundation/Foundation.h>
#import <Foundation/NSException.h>

// We use TET as a Objective-C class name, therefore hide the actual C struct
// name for TET usage with Objective-C.

typedef struct TET_s TET_objc;
#define TET TET_objc
#import "tetlib.h"
#undef  TET
    
        

@interface TETException : NSException
{
@private
    NSInteger _errnum;
    NSString *_apiname;
}

- (id) initWithErrmsg:(NSString *)errmsg errnum: (NSInteger) aErrnum apiname: (NSString *)aApiname;
- (NSInteger) get_errnum;
- (NSString *) get_apiname;
- (NSString *) get_errmsg;

@end

        
@interface TET : NSObject {
    TET_objc *_p;
    const TET_char_info  *_m_gi;
    const TET_color_info *_m_ci;
    const TET_image_info *_m_ii;
}   

// get_char_info/get_color_info/get_image_info getters
//
// http://cocoadevcentral.com/d/learn_objectivec/
// The dot syntax for getters and setters is new in Objective-C 2.0
// photo.caption = @"Day at the Beach";
// output = photo.caption;
// You can use either style, but choose only one for each project.

- (NSInteger) get_char_info: (NSInteger) page;
- (NSInteger) get_color_info: (NSInteger) doc colorid: (NSInteger) colorid optlist: (NSString *) optlist;
- (NSInteger) get_image_info: (NSInteger) page;
- (NSInteger) type;
- (double) x;
- (double) y;
- (double) width;
- (double) alpha;
- (double) beta;
- (NSInteger) fontid;
- (double) fontsize;
- (NSInteger) textrendering;
- (NSInteger) uv;
- (bool) unknown;
- (double) height;
- (NSInteger) imageid;
- (NSInteger) attributes;
- (NSInteger) colorid;
- (NSInteger) colorspaceid;
- (NSInteger) patternid;
- (NSArray *) components;
- (void) close_document: (NSInteger) doc;
- (void) close_page: (NSInteger) page;
- (void) create_pvf: (NSString *) filename data: (NSData *) data optlist: (NSString *) optlist;
- (NSInteger) delete_pvf: (NSString *) filename;
- (NSString *) get_apiname;
- (NSString *) get_errmsg;
- (NSInteger) get_errnum;
- (NSData *) get_image_data: (NSInteger) doc imageid: (NSInteger) imageid optlist: (NSString *) optlist;
- (NSString *) get_text: (NSInteger) page;
- (double) info_pvf: (NSString *) filename keyword: (NSString *) keyword;
- (NSInteger) open_document: (NSString *) filename optlist: (NSString *) optlist;
- (NSInteger) open_document_mem: (NSData *) data optlist: (NSString *) optlist;
- (NSInteger) open_page: (NSInteger) doc pagenumber: (NSInteger) pagenumber optlist: (NSString *) optlist;
- (double) pcos_get_number: (NSInteger) doc path: (NSString *) path;
- (NSString *) pcos_get_string: (NSInteger) doc path: (NSString *) path;
- (NSData *) pcos_get_stream: (NSInteger) doc optlist: (NSString *) optlist path: (NSString *) path;
- (void) set_option: (NSString *) optlist;
- (NSString *) convert_to_unicode: (NSString *) inputformat inputstring: (NSData *) inputstring optlist: (NSString *) optlist;
- (NSInteger) write_image_file: (NSInteger) doc imageid: (NSInteger) imageid optlist: (NSString *) optlist;
- (NSInteger) process_page: (NSInteger) doc pageno: (NSInteger) pageno optlist: (NSString *) optlist;
- (NSData *) get_xml_data: (NSInteger) doc optlist: (NSString *) optlist;
- (NSData *) get_tetml: (NSInteger) doc optlist: (NSString *) optlist;
@end
