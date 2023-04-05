package go;

import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.InputStream;
import java.io.File;
import java.io.IOException;
import java.io.*;


public class LoadJNI {
	static {
		try {
			loadLibrary();
		} catch (IOException ex) {
			throw new RuntimeException(ex);
		}
	}

	private static void loadLibrary() throws IOException {
		File temp = File.createTempFile("gojava", "gojava");
		temp.deleteOnExit();

		InputStream input = LoadJNI.class.getResourceAsStream("/go/libgojni.so");
		if (input == null) {
			if (input == null) {
				throw new RuntimeException("Go JNI library not found in classpath 2");
			}
		}

		// if (input != null) {
		// 	System.out.println(LoadJNI.class.getResource("/go/libgojni.so").toString());
		// }
		OutputStream out = new FileOutputStream(temp);

		try {
			byte[] buffer = new byte[1024];
			int readBytes = 0;
			while ((readBytes = input.read(buffer)) != -1) {
				out.write(buffer, 0, readBytes);
			}
		} finally {
			out.close();
			input.close();
		}
		System.load(temp.getAbsolutePath());
	}
}
