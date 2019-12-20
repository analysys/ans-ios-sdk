//
//  ANSAutoTrackCellProperty.h
//  AnalysysAgent
//
//  Created by xiao xu on 2019/10/25.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ANSAutoTrackCellProperty <NSObject>
/** Cell 路径 */
- (NSString *)analysysElementPosition:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
