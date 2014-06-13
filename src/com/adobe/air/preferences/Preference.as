/*
    Adobe Systems Incorporated(r) Source Code License Agreement
    Copyright(c) 2005 Adobe Systems Incorporated. All rights reserved.
    
    Please read this Source Code License Agreement carefully before using
    the source code.
    
    Adobe Systems Incorporated grants to you a perpetual, worldwide, non-exclusive, 
    no-charge, royalty-free, irrevocable copyright license, to reproduce,
    prepare derivative works of, publicly display, publicly perform, and
    distribute this source code and such derivative works in source or 
    object code form without any attribution requirements.  
    
    The name "Adobe Systems Incorporated" must not be used to endorse or promote products
    derived from the source code without prior written permission.
    
    You agree to indemnify, hold harmless and defend Adobe Systems Incorporated from and
    against any loss, damage, claims or lawsuits, including attorney's 
    fees that arise or result from your use or distribution of the source 
    code.
    
    THIS SOURCE CODE IS PROVIDED "AS IS" AND "WITH ALL FAULTS", WITHOUT 
    ANY TECHNICAL SUPPORT OR ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING,
    BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  ALSO, THERE IS NO WARRANTY OF 
    NON-INFRINGEMENT, TITLE OR QUIET ENJOYMENT.  IN NO EVENT SHALL ADOBE 
    OR ITS SUPPLIERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
    OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
    OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOURCE CODE, EVEN IF
    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
package com.adobe.air.preferences
{
	import flash.events.EventDispatcher;
	import flash.data.EncryptedLocalStore;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.*;
	import flash.utils.ByteArray;

	[Event(name=PreferenceChangeEvent.PREFERENCE_CHANGED_EVENT, type="com.adobe.air.notification.PreferenceChangeEvent")]

	public class Preference extends EventDispatcher
	{
		private var _modified: Boolean = false;
		private var _filename: String = null;

		private var _data: Object = {};

		public function Preference(filename: String = null)
		{
			super();
			registerClassAlias("com.adobe.air.preferences.PreferenceItem",  com.adobe.air.preferences.PreferenceItem);			
			if (filename == null)
			{
				this._filename = "_prefs.obj";
			}
			else
			{
				this._filename = filename;
			}
		}

		public function get modified(): Boolean
		{
			return this._modified;
		}

		private static const s_boolean: String = 'Boolean';
		private static const s_int: String = 'int';
		private static const s_uint: String = 'uint';
		private static const s_number: String = 'Number';
		private static const s_bytearray: String = 'ByteArray';

		public function setValue(name: String, value: *, encrypted: Boolean = false): void
		{
			var oldValue: * = this.getValue(name);
			this._modified = oldValue != value;
			if (this._modified)
			{
				var prefItm: PreferenceItem = new PreferenceItem();
				prefItm.encrypted = encrypted;
				if (encrypted)
				{
					var bytes:ByteArray = new ByteArray();
					if (value is Boolean)
					{
						prefItm.value = s_boolean;
						bytes.writeBoolean(value);
					}
					else if (value is int)
					{
						prefItm.value = s_int;
						bytes.writeByte(value);
					}
					else if (value is uint)
					{
						prefItm.value = s_uint;
						bytes.writeUnsignedInt(value);
					}
					else if (value is Number)
					{
						prefItm.value = s_number;
						bytes.writeDouble(value);
					}
					else if (value is ByteArray)
					{
						prefItm.value = s_bytearray;
						bytes.writeBytes(value);
					}
					else  // all other types including string
					{
						bytes.writeUTFBytes(value);
					}
					EncryptedLocalStore.setItem(name, bytes);
				}
				else
				{
					prefItm.value = value;
				}
				this._data[name] = prefItm;
				this.dispatchEvent(new PreferenceChangeEvent(PreferenceChangeEvent.ADD_EDIT_ACTION, name, oldValue, value));
			}
		}

		public function getValue(name: String, defaultValue: * = null): *
		{
			var result: * = defaultValue;
			if (this._data[name] != undefined)
			{
				var prefItm: PreferenceItem = PreferenceItem(this._data[name]);
				if (prefItm.encrypted)
				{
					var bytes:ByteArray = EncryptedLocalStore.getItem(name);
					if (bytes == null)
					{
						return defaultValue;
					}
					else if (prefItm.value == s_boolean)
					{
						result = bytes.readBoolean();
					}
					else if (prefItm.value == s_int)
					{
						result = bytes.readByte();
					}
					else if (prefItm.value == s_uint)
					{
						result = bytes.readUnsignedByte();
					}
					else if (prefItm.value == s_number)
					{
						result = bytes.readDouble();
					}
					else if (prefItm.value == s_bytearray)
					{
						result = new ByteArray();
						bytes.readBytes(result);
					}
					else  // all other types including string
					{
						result = bytes.readUTFBytes(bytes.length);
					}
				}
				else
				{
					result = prefItm.value;
				}
			}
			return result;
		}

		public function deleteValue(name: String): void
		{
			if (this._data[name] != undefined)
			{
				var oldValue:* = this.getValue(name);
				if (PreferenceItem(this._data[name]).encrypted)
				{
					EncryptedLocalStore.removeItem(name);
				}
				delete this._data[name];
				this._modified = true;
				this.dispatchEvent(new PreferenceChangeEvent(PreferenceChangeEvent.DELETE_ACTION, name, oldValue));
			}
		}

		public function save(): void
		{
			var prefsFile: File = File.applicationStorageDirectory.resolvePath(this._filename);
			var fs: FileStream = new FileStream();
			try
			{
				fs.open(prefsFile, FileMode.WRITE);
				fs.writeObject(this._data);
			}
			finally
			{
				fs.close();
			}
			this._modified = false;
		}

		public function load(): void
		{
			var prefsFile: File = File.applicationStorageDirectory.resolvePath(this._filename);
			if (prefsFile.exists)
			{
				var fs: FileStream = new FileStream();
				try
				{
					fs.open(prefsFile, FileMode.READ);
					this._data = fs.readObject();
				}
				finally
				{
					fs.close();
				}
			}
		}
	}
}