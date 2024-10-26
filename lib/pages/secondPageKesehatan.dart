import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sigita_final_project/models/sigitaModel.dart';
import 'package:sigita_final_project/navigasi/navigasiBar.dart';
import 'package:sigita_final_project/pages/view.dart';
import 'package:url_launcher/url_launcher.dart';

class PageProposal extends StatefulWidget {
  final String id;
  const PageProposal({super.key, required this.id});

  @override
  State<PageProposal> createState() => _PageProposalState();
}

class _PageProposalState extends State<PageProposal> {
  TextEditingController simpanKomentar = TextEditingController();
  TextEditingController simpanEmail = TextEditingController();
  TextEditingController simpanEmailDownload = TextEditingController();
  GetSigita dataRespon = GetSigita(
      id: "", title: "", content: "",file: "", date: "", category: "", jumlah: "", id_kategori: "");
  GetFile dataFile = GetFile(pdf: "");
  List<GetKomentar> dataKomentar = [];
  GetPesan dataPesan = GetPesan(pesan: "");

  @override
  void initState() {
    super.initState();
    // Fetch data on initialization
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Mengambil semua data secara bertahap
      final responData = await GetSigita.connApiDetail(widget.id);
      final fileData = await GetFile.getFile(widget.id);
      final komentarData = await GetKomentar.getKomentar(widget.id);
      final pesanData = await GetPesan.getPesan(widget.id);

      // Menggunakan setState hanya sekali untuk semua perubahan
      setState(() {
        dataRespon = responData;
        dataFile = fileData;
        dataKomentar = komentarData;
        dataPesan = pesanData;
      });
    } catch (e) {
      // Handle error
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    simpanKomentar.dispose();
    simpanEmail.dispose();
    simpanEmailDownload.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: const Navigasibar(), body: MainIndex());
  }

  SingleChildScrollView MainIndex() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Color.fromRGBO(202, 248, 253, 1),
                ],
                begin: Alignment.topCenter, // Titik awal gradien
                end: Alignment.bottomCenter, // Titik akhir gradien
              ),
            ),
            child: Column(
              children: [
                Image.network(
                    "https://news.ciptamedika.com/wp-content/uploads/2019/02/alatkesehatan.png"),
                Title(),
                Space(),
                const SizedBox(
                  height: 20,
                ),
                Description(),
                const SizedBox(
                  height: 40,
                ),
                const Text(
                  "Komentar",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Stack(alignment: Alignment.topCenter, children: [
                  Positioned(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  const Offset(0, 3), // changes position of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.circular(50),
                          color: const Color.fromARGB(255, 255, 255, 255)),
                      height: 380,
                      width: 390,
                      child: FutureBuilder<List<GetKomentar>>(
                        future: GetKomentar.getKomentar(
                            widget.id), // Panggilan untuk mendapatkan komentar
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(
                                child: Text('Harap Buka Ulang Aplikasi'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(child: Text('Belum Ada Komentar'));
                          } else {
                            List<GetKomentar> dataKomentar =
                                snapshot.data!; // Ambil data komentar
                            return ListView.separated(
                              shrinkWrap: true,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 5),
                              itemCount: dataKomentar.length,
                              itemBuilder: (context, index) {
                                var data = dataKomentar[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 30, top: 20, left: 0, right: 20),
                                  child: ListTile(
                                    title: Text(
                                      "${data.email}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19),
                                    ),
                                    subtitle: Text(
                                      "${data.komentar}",
                                      textAlign: TextAlign.justify,
                                    ),
                                    leading: const Icon(Icons.person_2),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  Comment(),
                ]),
                DownloadInformation()
              ],
            ),
          )
        ],
      ),
    );
  }

  Container DownloadInformation() {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 0, top: 40),
            child: Text(
              "Informasi Lebih Lanjut",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.black)),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Informasi Email"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: simpanEmailDownload,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(60),
                              ),
                              prefixIcon: const Icon(Icons.email_outlined),
                              labelText: "Masukkan Email",
                              hintText: "..@gmail.com",
                              hintStyle: TextStyle(
                                  color: Colors.grey.withOpacity(0.5)),
                            ),
                          )
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text("DOWNLOAD"),
                          onPressed: () async {
                            if (simpanEmailDownload.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 1),
                                  content: Text("Email Tidak Boleh Kosong"),
                                ),
                              );
                            } else {
                              launchUrl(Uri.parse(dataFile.pdf));
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text(
                "Download PDF",
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Viewpdfpage(
                                data: dataFile.pdf,
                              )));
                },
                child: const Text(
                  "Lihat Pdf",
                  style: TextStyle(color: Colors.black),
                ))
          ]),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Container Comment() {
    return Container(
      margin: const EdgeInsets.fromLTRB(6, 350, 6, 0),
      padding: const EdgeInsets.fromLTRB(15, 35, 15, 15),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.circular(50),
          color: const Color.fromARGB(255, 255, 255, 255)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 21, bottom: 5),
            child: Text(
              "Tinggalkan Komentar",
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.black)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            child: TextField(
              controller: simpanEmail,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(60)),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Colors.black,
                  ),
                  labelText: "Masukkan Email",
                  labelStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                  hintText: "..@gmail.com",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            child: TextField(
              controller: simpanKomentar,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(60),
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(60)),
                prefixIcon: const Icon(
                  Icons.pending,
                  color: Colors.black,
                ),
                labelText: "Masukkan Komentar",
                labelStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
              ),
              maxLines: null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 23, 15, 15),
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (simpanEmail.text.isEmpty || simpanKomentar.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Email dan Komentar harus diisi")),
                    );
                  } else {
                    await PostSigita.postSigita(
                        dataRespon.id, simpanEmail.text, simpanKomentar.text);
                    FocusScope.of(context).unfocus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Komentar Berhasil Dimasukkan")),
                    );
                  }
                },
                child: const Text(
                  "Simpan Komentar",
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Container Description() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      // height: 180,
      // color: Colors.blue,
      child: Text(
        dataRespon.content,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(textStyle: const TextStyle(fontSize: 18)),
      ),
    );
  }

  SizedBox Space() {
    return SizedBox(
      height: 100,
      // color: Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 15),
            width: 130,
            // color: Colors.blue,
            child: Column(
              children: [
                const Icon(
                  Icons.date_range,
                  size: 35,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  dataRespon.date,
                  style: GoogleFonts.poppins(
                      textStyle: const TextStyle(fontSize: 12)),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 20),
            width: 130,
            // color: Colors.green,
            child: Column(
              children: [
                const Icon(
                  Icons.book,
                  size: 30,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  dataRespon.category,
                  style: GoogleFonts.poppins(
                      textStyle: const TextStyle(fontSize: 15)),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 20),
            width: 100,
            // color: Colors.yellow,
            child: Column(
              children: [
                const Icon(
                  Icons.accessibility_new,
                  size: 30,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  "Jumlah ${dataRespon.jumlah}",
                  style: GoogleFonts.poppins(
                      textStyle: const TextStyle(fontSize: 15)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Center Title() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Text(dataRespon.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ))),
      ),
    );
  }
}
