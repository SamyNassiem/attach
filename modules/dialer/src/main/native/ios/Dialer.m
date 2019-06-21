/*
 * Copyright (c) 2016, 2019, Gluon
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL GLUON BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#import <UIKit/UIKit.h>
#include "jni.h"
#include "AttachMacros.h"

JNIEnv *env;

JNIEXPORT jint JNICALL
JNI_OnLoad_Dialer(JavaVM *vm, void *reserved)
{
#ifdef JNI_VERSION_1_8
    //min. returned JNI_VERSION required by JDK8 for builtin libraries
    if ((*vm)->GetEnv(vm, (void **)&env, JNI_VERSION_1_8) != JNI_OK) {
        return JNI_VERSION_1_4;
    }
    return JNI_VERSION_1_8;
#else
    return JNI_VERSION_1_4;
#endif
}

JNIEXPORT void JNICALL Java_com_gluonhq_attach_dialer_impl_IOSDialerService_callNumber
(JNIEnv *env, jclass jClass, jstring jNumber)
{
    const jchar *chars = (*env)->GetStringChars(env, jNumber, NULL);
    NSString *number = [NSString stringWithCharacters:(UniChar *)chars length:(*env)->GetStringLength(env, jNumber)];
    (*env)->ReleaseStringChars(env, jNumber, chars);
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",number]];
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        if (@available(iOS 10.0, *))
        {
            [[UIApplication sharedApplication] openURL:phoneUrl options:@{}
                completionHandler:nil];
        }
        else {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"

            [[UIApplication sharedApplication] openURL:phoneUrl];

            #pragma clang diagnostic pop
        }
        AttachLog(@"Done calling to %@", number);
    } else {
        AttachLog(@"Can't call to %@", number);
    }
}

