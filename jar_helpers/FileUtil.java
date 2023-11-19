// @license
// Author: Paa ( paa.code.me@gmail.com )
// Copyright: (c) 2023.

package jar_helpers;

import java.nio.file.*;
import java.io.*;
import java.util.*;

public class FileUtil {

    public static void main(String args[]) {
        if (args.length == 0) { no_param(); return; }
        switch(args[0]) {
            case "-d": do_default(); break;
            case "-s_assets": do_assets(); break;
            case "-s_config": do_config(); break;
            case "-m_output": mv_build(); break;
            default: no_param(); break;
        }
    }

    // Handle build .apk move
    private static void mv_build() {
        File[] b_output = new File("base_app/build/app/outputs/flutter-apk").listFiles();
        for (int a = 0;a < b_output.length; a++) {
            b_output[a].renameTo(new File("output/"+ b_output[a].getName()));
        }
        echo("FileUtil: APK Generated To `output` DIR.", 0);
    }

    // Handle config sync
    private static void do_config() {
        File d_config = new File("gen_config.json");
        File b_config = new File("base_app/assets/raw/config.json");
        if (!d_config.exists() || !b_config.exists()) {
            echo("Either `gen_config.json` Or `base_app/assets/raw/config.json` Not Found", 5);
        }
        String d_c_contents = readFile( d_config );
        if (d_c_contents.trim().length() <= 0) {
            echo("Config Value-Sets Cannot Be Empty", 6);
        }
        JSONObject d_c_json;
        try { d_c_json = new JSONObject(d_c_contents); }
        catch (JSONException err) { echo("Issue Parsing Config Data", 6); return;
        }
        String appName, appIcon, splashIcon, baseUrl, colorPrimary, colorAccent;
        boolean pullToRefresh;
        try {
            appName = d_c_json.getString("appName");
            appIcon = d_c_json.getString("appIcon");
            splashIcon = d_c_json.getString("splashIcon");
            baseUrl = d_c_json.getString("baseUrl");
            colorPrimary = d_c_json.getString("colorPrimary");
            colorAccent = d_c_json.getString("colorAccent");
            pullToRefresh = d_c_json.getBoolean("pullToRefresh");
        }
        catch (JSONException err) {
            echo(
                "Unable To Find Mandatory Config Values\n\nMandatory Values:\n"+
                "- appName\n- appIcon\n- splashIcon\n- baseUrl\n- colorPrimary\n- colorAccent\n- pullToRefresh\n\n"+
                "For more info, check `readme.txt`.", 
                7
            );
            return;
        }
        appName = appName.trim().length() == 0 ? "Genar" : appName;
        appIcon = appIcon.trim().length() == 0 ? "app_icon_to_gen.png" : appIcon;
        splashIcon = splashIcon.trim().length() == 0 ? "" : splashIcon;
        baseUrl = baseUrl.trim().length() == 0 ? "https://google.com" : baseUrl;
        if (colorPrimary.trim().length() > 0) { if (!check_color(colorPrimary)) {
            echo(
                "Invalid `colorPrimary` Value.\n\nValue Must Be A `7 length Color Hex` String.\n\n"+
                "For more info, check `readme.txt`.", 8
            ); return;
        } }
        else {
            colorPrimary = "#673AB7";
        }
        if (colorAccent.trim().length() > 0) { if (!check_color(colorAccent)) {
            echo(
                "Invalid `colorAccent` Value.\n\nValue Must Be A `7 length Color Hex` String.\n\n"+
                "For more info, check `readme.txt`.", 8
            ); return;
        } }
        else {
            colorAccent = "#7E525D";
        }
        String icon_path = appIcon.equals("app_icon_to_gen.png")
                           ? "base_app/assets/raw/app_icon_to_gen.png"
                           : "base_app/assets/build/" + appIcon;
        String s_icon_path = splashIcon.equals("app_icon_splash.png")
                             ? "base_app/assets/raw/app_icon_splash.png"
                             : "base_app/assets/build/" + splashIcon;
        if (!new File(icon_path).exists() || !new File(s_icon_path).exists()) {
            echo("Either App Or Splash Icon Cannot Be Found", 9); return;
        }
        icon_path = icon_path.substring(9, icon_path.length());
        s_icon_path = s_icon_path.substring(9, s_icon_path.length());
        String[] p_spec = readFile(new File("base_app/pubspec.yaml")).split("\n");
        for (int a = 0; a < p_spec.length; a++) {
            if (
                p_spec[a].contains("image_path:") || p_spec[a].contains("adaptive_icon_foreground:")
            ) {
                p_spec[a] = p_spec[a].replaceAll("\"([^\"]*)\"", "\""+ icon_path +"\"");
            }
            if (
                p_spec[a].contains("adaptive_icon_background:") || p_spec[a].contains("background_color:") ||
                p_spec[a].contains("theme_color:")
            ) {
                p_spec[a] = p_spec[a].replaceAll("\"([^\"]*)\"", "\""+ colorPrimary +"\"");
            }
        }
        String new_pubspec = String.join("\n", p_spec);
        if (!writeFile( new_pubspec + "\n",  "base_app/pubspec.yaml" )) {
            echo("Unable To Update `pubspec.yaml`", 10); return;
        }
        String a_m_path = "base_app/android/app/src/main/AndroidManifest.xml";
        String[] a_manifest = readFile(new File(a_m_path)).split("\n");
        for (int a = 0;a < a_manifest.length; a++) {
            if (a_manifest[a].contains("android:label=")) {
                a_manifest[a] = a_manifest[a].replaceAll("\"([^\"]*)\"", "\""+ appName +"\"");
            }
        }
        String new_manifest = String.join("\n", a_manifest);
        if (!writeFile( new_manifest + "\n", a_m_path )) {
            echo("Unable To Update `base_app/../AndroidManifest.xml`", 11); return;
        }
        String[] st_co = readFile(new File("base_app/android/app/src/main/res/values/styles.xml")).split("\n");
        for (int a = 0;a < st_co.length; a++) {
            if (st_co[a].contains("android:navigationBarColor")) {
                st_co[a] = st_co[a].replaceAll("(>).*(<)", ">"+ colorPrimary +"<");
            }
            if (st_co[a].contains("android:windowBackground")) {
                st_co[a] = st_co[a].replaceAll("(>).*(<)", ">"+ colorPrimary +"<");
            }
        }
        String st_nc = String.join("\n", st_co);
        writeFile( st_nc, "base_app/android/app/src/main/res/values/styles.xml" );
        writeFile( st_nc, "base_app/android/app/src/main/res/values-night/styles.xml" );
        String a_c_path = "base_app/lib/constants.dart";
        String[] a_constants = readFile(new File(a_c_path)).split("\n");
        for (int a = 0;a < a_constants.length; a++) {
            if (a_constants[a].contains("appName")) {
                a_constants[a] = a_constants[a].replaceAll("\"([^\"]*)\"", "\""+ appName +"\"");
            }
            if (a_constants[a].contains("splashIcon")) {
                a_constants[a] = a_constants[a].replaceAll("\"([^\"]*)\"", "\""+ s_icon_path +"\"");
            }
            if (a_constants[a].contains("colorPrimary")) {
                a_constants[a] = a_constants[a].replaceAll("(?<=\\()(.*?)(?=\\))", 
                    "0xFF"+ colorPrimary.substring(1, colorPrimary.length()));
            }
            if (a_constants[a].contains("colorAccent")) {
                a_constants[a] = a_constants[a].replaceAll("(?<=\\()(.*?)(?=\\))", 
                    "0xFF"+ colorAccent.substring(1, colorAccent.length()));
            }
        }
        String new_a_c = String.join("\n", a_constants);
        if (!writeFile( new_a_c + "\n", a_c_path )) {
            echo("Unable To Update `base_app/lib/constants.dart`", 13); return;
        }
        String cnfg_content = readFile( new File("gen_config.json") );
        if (!writeFile(cnfg_content, "base_app/assets/raw/config.json")) {
            echo("Unable To Update `base_app/assets/raw/config.json` with `gen_config.json`", 14);
        }
        echo("FileUtil: `base_app` Sync Successful.", 0);
    }

    // Handle color validation
    private static boolean check_color(String color) {
        if ((color.trim().length() == 7) && (color.substring(0,1).equals("#"))) { return true;
        }
        return false;
    }

    // Handle assets sync
    private static void do_assets() {
        File d_folder = new File("gen_assets");
        File b_folder = new File("base_app/assets/build");
        if (!d_folder.exists() || !b_folder.exists()) {
            echo("Either `base_app/assets/build/` Or `gen_assets` Not Found", 5);
        }
        File[] deflt_assets = d_folder.listFiles();
        File[] build_assets = b_folder.listFiles();
        for (int a = 0; a < build_assets.length; a++) { build_assets[a].delete();
        }
        for (int a = 0; a < deflt_assets.length; a++) {
            String file_name = deflt_assets[a].getName();
            try {
                Files.copy(
                    deflt_assets[a].toPath(), new File("base_app/assets/build/" + file_name).toPath(),
                    StandardCopyOption.REPLACE_EXISTING
                );
            } catch(IOException e) {}
        }
        echo("FileUtil: `base_app/assets/` Update Successful.", 0);
    }

    // Handle default files setup
    private static void do_default() {
        File deft_pub = new File("def_pub.txt");
        File base_pub = new File("base_app/pubspec.yaml");
        File cnfg_pub = new File("gen_config.json");
        if (!deft_pub.exists() || !base_pub.exists() || !cnfg_pub.exists()) {
            echo("Either `def_pub.txt` Or `base_app/pubspec.yaml` Or `gen_confog.json` Does Not Exist.", 5);
        }
        String deft_content = readFile( deft_pub );
        String base_content = readFile( base_pub );
        if (!writeFile( base_content + deft_content,  "base_app/"+ base_pub.getName() )) {
            echo("Unable to merge `def_pub.txt` & `base_app/pubspec.yaml`", 5);
        }
        if (!new File("base_app/assets/").mkdir()) {
            echo("Unable to create `assets` in `base_app`", 5);
        }
        new File("base_app/assets/raw/").mkdir();
        new File("base_app/assets/build/").mkdir();
        String cnfg_content = readFile( cnfg_pub );
        if (!writeFile(cnfg_content, "base_app/assets/raw/config.json")) {
            echo("Unable to create `config.json` in `base_app/assets/raw/`", 5);
        }
        File[] deft_fls = new File("gen_assets/icons").listFiles();
        for (int a = 0;a < deft_fls.length;a++) {
            deft_fls[a].renameTo(new File("base_app/assets/raw/"+ deft_fls[a].getName()));
        }
        String styl_content = readFile( new File("gen_assets/extras/styles.xml") );
        writeFile( styl_content + "\n", "base_app/android/app/src/main/res/values-night/styles.xml" );
        writeFile( styl_content + "\n", "base_app/android/app/src/main/res/values/styles.xml" );
        new File("gen_assets/extras/styles.xml").delete();
        new File("gen_assets/extras").delete();
        new File("gen_assets/icons").delete();
        String b_gradle_p = "base_app/android/app/build.gradle";
        String[] b_gradle_c = readFile( new File(b_gradle_p) ).split("\n");
        for (int a = 0; a < b_gradle_c.length; a++) {
            if (b_gradle_c[a].contains("minSdkVersion")) {
                b_gradle_c[a] = b_gradle_c[a].replaceAll("flutter.minSdkVersion", "19");
            }
            if (b_gradle_c[a].contains("compileSdkVersion")) {
                b_gradle_c[a] = b_gradle_c[a].replaceAll("flutter.compileSdkVersion", "33");
            }
            if (b_gradle_c[a].contains("targetSdkVersion")) {
                b_gradle_c[a] = b_gradle_c[a].replaceAll("flutter.targetSdkVersion", "33");
            }
        }
        String b_gradle_n = String.join("\n", b_gradle_c);
        writeFile( b_gradle_n + "\n", b_gradle_p );
        new File("base_app/lib/main.dart").delete();
        File[] base_lib = new File("gen_assets/base_lib/").listFiles();
        for (int a = 0; a < base_lib.length; a++) {
            base_lib[a].renameTo(new File("base_app/lib/"+ base_lib[a].getName()));
        }
        new File("gen_assets/base_lib").delete();
        String a_man_p = "base_app/android/app/src/main/AndroidManifest.xml";
        String[] a_man_c = readFile( new File(a_man_p) ).split("\n");
        for (int a = 0; a < a_man_c.length; a++) { if (a_man_c[a].contains("<application")) {
            a_man_c[a] = "<uses-permission android:name=\"android.permission.INTERNET\"/>\n"+ 
                         a_man_c[a] +" \n android:usesCleartextTraffic=\"true\"";
        } }
        String a_man_n = String.join("\n", a_man_c);
        writeFile( a_man_n + "\n", a_man_p );
        String gw_p = "base_app/android/gradle/wrapper/gradle-wrapper.properties";
        String[] gw_c = readFile( new File(gw_p) ).split("\n");
        for (int a = 0; a < gw_c.length; a++) {
            if (gw_c[a].contains("distributionUrl")) {
                gw_c[a] = "distributionUrl=https\\://services.gradle.org/distributions/gradle-8.1.1-all.zip";
            }
        }
        String gw_n = String.join("\n", gw_c);
        writeFile( gw_n + "\n", gw_p );
        String pb_p = "base_app/android/build.gradle";
        String[] pb_c = readFile( new File(pb_p) ).split("\n");
        for (int a = 0; a < pb_c.length; a++) {
            if (pb_c[a].contains("allprojects")) {
                pb_c[a + 4] = pb_c[a + 4] + "\n\ttasks.withType(JavaCompile){ options.compilerArgs << '-Xlint:-options' }";
            }
            if (pb_c[a].contains("com.android.tools.build:gradle")) {
                pb_c[a] = "\tclasspath 'com.android.tools.build:gradle:7.4.2'";
            }
        }
        String pb_n = String.join("\n", pb_c);
        writeFile( pb_n + "\n", pb_p );
        String ab_p = "base_app/android/app/build.gradle";
        String[] ab_c = readFile( new File(ab_p) ).split("\n");
        for (int a = 0; a < ab_c.length; a++) {
            if (ab_c[a].contains("signingConfig signingConfigs.debug")) {
                ab_c[a] = ab_c[a] + "\n\t\t\tshrinkResources false";
            }
        }
        String ab_n = String.join("\n", ab_c);
        writeFile( ab_n + "\n", ab_p );
        echo("FileUtil: `base_app` Setup Successful.", 0);
    }

    // Write file contents
    private static boolean writeFile(String data, String destination) {
        try {
            FileWriter myWriter = new FileWriter( destination ); myWriter.write(data); myWriter.close();
            return true;
        } catch (IOException e) { e.printStackTrace(); return false;
        }
    }

    // Read file contents
    private static String readFile(File origin) {
        String content = "";
        try {
            Scanner myReader = new Scanner( origin );
            while (myReader.hasNextLine()) { content += myReader.nextLine() + "\n"; }
            myReader.close();
        } catch (FileNotFoundException e) { e.printStackTrace();
        }
        return content;
    }

    // Print message
    private static void echo(String message, int returnCode) { System.out.println("\t" + message); System.exit(returnCode);
    }

    // Handle no param error
    private static void no_param() {
        System.out.println("FileUtil requires either -d or -s_assets or -s_config arguments");
        System.exit(1);
    }
}
