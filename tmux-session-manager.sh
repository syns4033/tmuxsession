#!/data/data/com.termux/files/usr/bin/bash

# Fungsi untuk mencetak teks dengan warna
print_colored() {
    local color=$1
    local text=$2
    echo -e "\e[1;${color}m${text}\e[0m"
}

# Fungsi untuk menampilkan session dengan nomor urut
display_sessions() {
    local sessions
    sessions=$(tmux list-sessions 2>/dev/null)
    
    if [[ -z "$sessions" ]]; then
        print_colored 31 "Tidak ada session yang ditemukan."
        return 1
    fi

    print_colored 32 "Daftar session aktif:"
    echo "$sessions" | nl -w2 -s'. ' | while read -r line; do
        echo "$line"
    done
}

while true; do
    print_colored 32 "Pilihan:"
    print_colored 34 "1. Buat session"
    print_colored 34 "2. Cek session"
    print_colored 34 "3. Pindah ke session lainnya"
    print_colored 34 "4. Hapus 1 session"
    print_colored 34 "5. Hapus semua session"
    print_colored 34 "6. Keluar"
    
    read -p "$(print_colored 33 "Masukkan pilihan (1-6): ")" choice

    case $choice in
        1)
            read -p "$(print_colored 33 "Masukkan nama untuk session baru: ")" new_session_name
            
            # Membuat session baru dengan nama yang diberikan dan langsung detach
            tmux new-session -d -s "$new_session_name"
            
            print_colored 32 "Session baru '$new_session_name' telah dibuat dan di-detach."
            display_sessions # Memperbarui daftar session setelah membuat yang baru.
            ;;
        2)
            display_sessions
            ;;
        3)
            if display_sessions; then
                read -p "$(print_colored 33 "Masukkan nama atau nomor urut session yang ingin dipindah: ")" user_input
                
                # Memeriksa apakah input adalah angka dan dalam rentang yang valid
                if [[ "$user_input" =~ ^[0-9]+$ ]]; then
                    # Mendapatkan nama berdasarkan nomor urut yang dimasukkan pengguna
                    session_name=$(tmux list-sessions | sed -n "${user_input}p" | cut -d ':' -f1)
                    
                    if [[ -n "$session_name" ]]; then
                        tmux attach-session -t "$session_name"
                        print_colored 32 "Berpindah ke session $session_name."
                    else
                        print_colored 31 "Nomor urut tidak valid."
                    fi
                else
                    # Jika input bukan angka, anggap itu adalah nama langsung
                    if tmux has-session -t "$user_input" 2>/dev/null; then
                        tmux attach-session -t "$user_input"
                        print_colored 32 "Berpindah ke session $user_input."
                    else
                        print_colored 31 "Nama session tidak valid."
                    fi
                fi
            else
                print_colored 31 "Tidak ada session untuk dipindah."
            fi
            ;;
        4)
            if display_sessions; then
                read -p "$(print_colored 33 "Masukkan nama atau nomor urut session yang ingin dihapus: ")" user_input
                
                # Memeriksa apakah input adalah angka dan dalam rentang yang valid
                if [[ "$user_input" =~ ^[0-9]+$ ]]; then
                    # Mendapatkan nama berdasarkan nomor urut yang dimasukkan pengguna
                    session_name=$(tmux list-sessions | sed -n "${user_input}p" | cut -d ':' -f1)
                    
                    if [[ -n "$session_name" ]]; then
                        tmux kill-session -t "$session_name"
                        print_colored 32 "Session $session_name telah dihapus."
                    else
                        print_colored 31 "Nomor urut tidak valid."
                    fi
                else
                    # Jika input bukan angka, anggap itu adalah nama langsung
                    if tmux has-session -t "$user_input" 2>/dev/null; then
                        tmux kill-session -t "$user_input"
                        print_colored 32 "Session $user_input telah dihapus."
                    else
                        print_colored 31 "Nama session tidak valid."
                    fi
                fi
            else
                print_colored 31 "Tidak ada session untuk dihapus."
            fi
            ;;
        5)
            if display_sessions; then
                read -p "$(print_colored 33 "Apakah Anda yakin ingin menghapus semua session? (y/n): ")" confirm
                
                if [[ "$confirm" == [yY] ]]; then
                    tmux kill-server
                    print_colored 32 "Semua session telah dihapus."
                else
                    print_colored 31 "Penghapusan semua session dibatalkan."
                fi
            else
                print_colored 31 "Tidak ada session untuk dihapus."
            fi
            ;;
        6)
            print_colored 31 "Keluar dari script..."
            break
            ;;
        *)
            print_colored 31 "Pilihan tidak valid. Silakan coba lagi."
            ;;
    esac
done
